import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(supabase: Supabase.instance.client);
});

// Auth state provider
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final result = await repo.getCurrentUser();
  return result.fold((_) => null, (user) => user);
});

// Auth controller
class AuthController extends StateNotifier<AuthState> {
  AuthController({required this.authRepository}) : super(const AuthState.initial());

  final AuthRepository authRepository;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    final result = await authRepository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    final result = await authRepository.signInWithGoogle();
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signInWithApple() async {
    state = const AuthState.loading();
    final result = await authRepository.signInWithApple();
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    final result = await authRepository.signOut();
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.unauthenticated(),
    );
  }

  Future<void> resetPassword(String email) async {
    state = const AuthState.loading();
    final result = await authRepository.resetPassword(email);
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.passwordResetSent(),
    );
  }

  Future<void> deleteAccount() async {
    state = const AuthState.loading();
    final result = await authRepository.deleteAccount();
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.unauthenticated(),
    );
  }

  void clearError() {
    if (state is _AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth state sealed class
sealed class AuthState {
  const AuthState();
  const factory AuthState.initial() = _AuthStateInitial;
  const factory AuthState.loading() = _AuthStateLoading;
  const factory AuthState.authenticated(UserEntity user) = _AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = _AuthStateUnauthenticated;
  const factory AuthState.error(String message) = _AuthStateError;
  const factory AuthState.passwordResetSent() = _AuthStatePasswordResetSent;
}

class _AuthStateInitial extends AuthState {
  const _AuthStateInitial();
}

class _AuthStateLoading extends AuthState {
  const _AuthStateLoading();
}

class _AuthStateAuthenticated extends AuthState {
  const _AuthStateAuthenticated(this.user);
  final UserEntity user;
}

class _AuthStateUnauthenticated extends AuthState {
  const _AuthStateUnauthenticated();
}

class _AuthStateError extends AuthState {
  const _AuthStateError(this.message);
  final String message;
}

class _AuthStatePasswordResetSent extends AuthState {
  const _AuthStatePasswordResetSent();
}

// Provider for auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});
