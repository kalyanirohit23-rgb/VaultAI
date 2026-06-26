import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  const Failure([this.message = '']);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server / API failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Cache / local storage failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

/// Storage limit reached
class StorageLimitFailure extends Failure {
  const StorageLimitFailure([super.message = 'Storage limit reached']);
}

/// File too large
class FileSizeFailure extends Failure {
  const FileSizeFailure([super.message = 'File size exceeds limit']);
}

/// Unsupported file type
class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure([super.message = 'Unsupported file type']);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
