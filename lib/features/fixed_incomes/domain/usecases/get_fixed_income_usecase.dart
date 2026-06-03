import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/data/repositories/fixed_income_repository.dart';

class GetFixedIncomesUseCase {
  final FixedIncomeRepository repository;
  GetFixedIncomesUseCase(this.repository);

  Future<Either<Failure, List<FixedIncomeModel>>> call() async {
    return await repository.getFixedIncomes();
  }
}
