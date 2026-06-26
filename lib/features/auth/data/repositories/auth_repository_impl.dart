import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.supabase});

  final SupabaseClient supabase;
  final _logger = Logger();

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(AuthFailure('Sign in failed'));
      }

      final profile = await _fetchProfile(response.user!.id);
      final user = UserModel.fromSupabaseUser(response.user!, profile: profile);
      return Right(user);
    } on AuthException catch (e) {
      _logger.e('Auth error during sign in', error: e);
      return Left(AuthFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error during sign in', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': displayName},
      );

      if (response.user == null) {
        return const Left(AuthFailure('Registration failed'));
      }

      // Create profile
      await supabase.from('profiles').upsert({
        'id': response.user!.id,
        'display_name': displayName,
        'email': email,
        'subscription_tier': 'free',
        'storage_used': 0,
        'document_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      final user = UserModel.fromSupabaseUser(response.user!);
      return Right(user);
    } on AuthException catch (e) {
      _logger.e('Auth error during sign up', error: e);
      return Left(AuthFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error during sign up', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.vaultai://login-callback',
      );

      final user = supabase.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Google sign in failed'));
      }

      final profile = await _fetchProfile(user.id);
      return Right(UserModel.fromSupabaseUser(user, profile: profile));
    } catch (e) {
      _logger.e('Google sign in error', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.vaultai://login-callback',
      );

      final user = supabase.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Apple sign in failed'));
      }

      final profile = await _fetchProfile(user.id);
      return Right(UserModel.fromSupabaseUser(user, profile: profile));
    } catch (e) {
      _logger.e('Apple sign in error', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      _logger.e('Sign out error', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return const Right(null);

      final profile = await _fetchProfile(user.id);
      return Right(UserModel.fromSupabaseUser(user, profile: profile));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // In production, this would call a Supabase Edge Function
      // that handles cascading deletes and storage cleanup
      await supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendEmailVerification() async {
    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) return const Left(AuthFailure('No user logged in'));

      await supabase.auth.resend(type: OtpType.email, email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      final profile = await _fetchProfile(user.id);
      return UserModel.fromSupabaseUser(user, profile: profile);
    });
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
