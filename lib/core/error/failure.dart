// core/error/failures.dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class BudgetExceededFailure extends Failure {
  BudgetExceededFailure([String message = "Budget exceeded"]) : super(message);
}
