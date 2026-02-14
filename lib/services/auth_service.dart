import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Link anonymous account to Apple Sign-In via OAuth.
  Future<void> linkAppleSignIn() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.chompd.app://login-callback/',
    );
  }

  /// Link anonymous account to Google Sign-In via OAuth.
  Future<void> linkGoogleSignIn() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.chompd.app://login-callback/',
    );
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
}
