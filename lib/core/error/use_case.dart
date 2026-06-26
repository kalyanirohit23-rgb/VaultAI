import 'package:dartz/dartz.dart';

import 'failures.dart';

/// Type alias for Either with Failure on left and T on right
typedef Result<T> = Either<Failure, T>;

/// Base use case interface
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// No parameters sentinel class
class NoParams {
  const NoParams();
}
