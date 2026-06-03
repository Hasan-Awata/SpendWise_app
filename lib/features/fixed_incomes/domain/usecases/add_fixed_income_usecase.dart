import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';

class AddFixedIncomeUseCase {
  final FixedIncomeRepository repository;
  AddFixedIncomeUseCase(this.repository);

  Future<Either<Failure, String>> call(FixedIncomeModel model) async {
    return await repository.addFixedIncome(model);
  }
}
