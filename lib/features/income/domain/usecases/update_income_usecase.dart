import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;

  UpdateIncomeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(IncomeEntity income) async {
    return await repository.updateIncome(income);
  }
}
