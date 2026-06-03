import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';

abstract class FixedIncomeRepository {
  FixedIncomeRepository();

  Future<Either<Failure, String>> addFixedIncome(FixedIncomeModel model);

  Future<Either<Failure, Unit>> updateFixedIncome(FixedIncomeModel model);

  Future<Either<Failure, Unit>> deleteFixedIncome(FixedIncomeModel model);

  Future<Either<Failure, List<FixedIncomeModel>>> getFixedIncomes();
}
