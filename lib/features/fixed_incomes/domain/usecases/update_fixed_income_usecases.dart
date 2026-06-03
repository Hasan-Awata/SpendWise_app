// lib/features/fixed_income/domain/usecases/
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';

class UpdateFixedIncomeUseCase {
  final FixedIncomeRepository repository;
  UpdateFixedIncomeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(FixedIncomeModel model) async {
    return await repository.updateFixedIncome(model);
  }
}
