import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> resendEmailVerification();

  Stream<UserEntity?> get authStateChanges;
}
