import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';

class DeleteFixedIncomeUseCase {
  final FixedIncomeRepository repository;
  DeleteFixedIncomeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(FixedIncomeModel model) async {
    return await repository.deleteFixedIncome(model);
  }
}
