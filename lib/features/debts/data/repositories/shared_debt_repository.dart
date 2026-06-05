import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';

abstract class SharedDebtRepository {
  // =========================
  // GET DEBTS
  // =========================
  Future<Either<Failure, List<SharedDebtEntity>>> getDebts(int? userId);

  // =========================
  // CREATE
  // =========================
  Future<Either<Failure, String>> addDebt(SharedDebtEntity debt);

  // =========================
  // UPDATE
  // =========================
  Future<Either<Failure, Unit>> updateDebt(SharedDebtEntity debt);

  // =========================
  // DELETE
  // =========================
  Future<Either<Failure, Unit>> deleteDebt(SharedDebtEntity debt);
}
