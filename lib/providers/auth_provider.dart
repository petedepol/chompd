import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Authentication status.
enum AuthStatus {
  initialising,
  anonymous,
  signedIn,
  offline,
}

/// Immutable auth state.
class AuthServiceState {
  final AuthStatus status;
  final String? userId;
  final String? email;

  const AuthServiceState({
    this.status = AuthStatus.initialising,
    this.userId,
    this.email,
  });

  AuthServiceState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
  }) {
    return AuthServiceState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}

/// Manages auth state and listens for auth changes.
class AuthNotifier extends StateNotifier<AuthServiceState> {
  StreamSubscription<dynamic>? _authSub;

  AuthNotifier() : super(const AuthServiceState()) {
    _init();
  }

  void _init() {
    // Set initial state from current session
    final auth = AuthService.instance;
    if (auth.isSignedIn) {
      state = AuthServiceState(
        status: auth.isAnonymous ? AuthStatus.anonymous : AuthStatus.signedIn,
        userId: auth.userId,
        email: auth.email,
      );
    } else {
      state = const AuthServiceState(status: AuthStatus.offline);
    }

    // Listen for auth changes (sign-in, sign-out, token refresh)
    try {
      _authSub = auth.onAuthStateChange.listen((event) {
        if (!mounted) return;
        final user = event.session?.user;
        if (user == null) {
          state = const AuthServiceState(status: AuthStatus.offline);
        } else {
          state = AuthServiceState(
            status:
                user.isAnonymous ? AuthStatus.anonymous : AuthStatus.signedIn,
            userId: user.id,
            email: user.email,
          );
        }
      });
    } catch (e) {
      debugPrint('[AuthProvider] Stream error: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    super.dispose();
  }
}

/// Provider: auth state.
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthServiceState>((ref) {
  return AuthNotifier();
});

/// Convenience: whether user is anonymous.
final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.anonymous;
});

/// Convenience: current user ID.
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});
