import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_logger.dart';

/// Handles anonymous auth and account upgrade.
///
/// Singleton following the existing service pattern.
/// On first launch, creates an anonymous user.
/// Users can later link Apple/Google/Email to preserve data.
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  /// Whether Supabase was initialized with valid credentials.
  bool get isConfigured =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty;

  SupabaseClient get _client => Supabase.instance.client;

  /// Ensure a user session exists. Creates anonymous user if none.
  Future<User> ensureUser() async {
    final current = _client.auth.currentUser;
    if (current != null) return current;
    final response = await _client.auth.signInAnonymously();
    return response.user!;
  }

  /// Whether the current user is anonymous (not linked to a provider).
  bool get isAnonymous =>
      !isConfigured || (_client.auth.currentUser?.isAnonymous ?? true);

  /// Whether any user session exists.
  bool get isSignedIn =>
      isConfigured && _client.auth.currentUser != null;

  /// Current user UUID (null if not signed in).
  String? get userId =>
      isConfigured ? _client.auth.currentUser?.id : null;

  /// Current user email (null if anonymous).
  String? get email =>
      isConfigured ? _client.auth.currentUser?.email : null;

  /// Sign in with Apple — restores existing accounts on reinstall.
  ///
  /// On a fresh install the app creates an anonymous user. When the user
  /// taps "Sign in with Apple", we need to check whether an Apple-linked
  /// account already exists in Supabase:
  ///
  /// 1. Get the Apple credential (native sheet).
  /// 2. Sign out of the current anonymous session so [signInWithIdToken]
  ///    returns the **existing** Apple-linked user instead of linking to
  ///    the throwaway anonymous account.
  /// 3. Call [signInWithIdToken] — Supabase returns the existing user if
  ///    one is found, or creates a new one.
  ///
  /// Returns `true` if an existing account was restored (user ID changed),
  /// `false` if this was a first-time Apple sign-in.
  ///
  /// Throws [AppleSignInCancelledException] if the user dismissed the sheet.
  /// Throws [AppleSignInException] for all other failures.
  Future<bool> linkAppleSignIn() async {
    // Generate a cryptographically secure nonce.
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      // Present the native Apple Sign-In sheet.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw AppleSignInException('Apple returned no identity token.');
      }

      // Remember the current anonymous user ID.
      final previousUserId = _client.auth.currentUser?.id;
      final wasAnonymous = _client.auth.currentUser?.isAnonymous ?? true;

      // Sign out of the anonymous session BEFORE calling signInWithIdToken.
      // Without this, Supabase links Apple to the current anonymous user
      // instead of returning the existing Apple-linked account.
      if (wasAnonymous) {
        await _client.auth.signOut();
      }

      // Sign in with the Apple credential.
      // Supabase will return the existing Apple-linked user if one exists,
      // or create a brand new user.
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final newUserId = _client.auth.currentUser?.id;
      final restored = previousUserId != null && newUserId != previousUserId;

      return restored;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AppleSignInCancelledException();
      }
      ErrorLogger.log(event: 'auth_error', detail: 'Apple auth exception: $e');
      throw AppleSignInException(
        'Apple sign-in failed. Please try again.',
      );
    } catch (e, st) {
      // Re-throw our own exceptions unchanged.
      if (e is AppleSignInCancelledException || e is AppleSignInException) {
        rethrow;
      }
      ErrorLogger.log(event: 'auth_error', detail: 'Apple sign-in: $e', stackTrace: st.toString());
      throw AppleSignInException(
        'Something went wrong. Please try again.',
      );
    }
  }

  /// Link anonymous account to email/password.
  Future<void> linkEmail(String email, String password) async {
    await _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  /// Sign out (data remains in local Isar).
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Auth state change stream for listening to sign-in/sign-out events.
  Stream<AuthState> get onAuthStateChange =>
      isConfigured ? _client.auth.onAuthStateChange : const Stream.empty();

  /// Generate a cryptographically secure random nonce (32 bytes, URL-safe).
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}

/// Thrown when the user cancels the Apple Sign-In sheet.
/// UI should fail silently — no error message needed.
class AppleSignInCancelledException implements Exception {}

/// Thrown for non-cancellation Apple Sign-In errors.
class AppleSignInException implements Exception {
  final String message;
  const AppleSignInException(this.message);

  @override
  String toString() => message;
}
