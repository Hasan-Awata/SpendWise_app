import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/debts/data/repositories/shared_debt_repository.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';

class AddDebtUseCase {
  final SharedDebtRepository repository;

  AddDebtUseCase(this.repository);

  Future<Either<Failure, String>> call(SharedDebtEntity debt) {
    return repository.addDebt(debt);
  }
}
