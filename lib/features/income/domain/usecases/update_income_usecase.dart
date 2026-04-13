import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;

  UpdateIncomeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int incomeId, IncomeModel income) async {
    return await repository.updateIncome(incomeId, income);
  }
}
