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
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}

// Auth state sealed class
sealed class AuthState {
  const AuthState();
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(UserEntity user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
  const factory AuthState.passwordResetSent() = AuthStatePasswordResetSent;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final UserEntity user;
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  const AuthStateError(this.message);
  final String message;
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

// Provider for auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});
