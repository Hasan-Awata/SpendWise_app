import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class DeleteIncomeUseCase {
  final IncomeRepository repository;

  DeleteIncomeUseCase(this.repository);

  Future<Either<Failure, Unit>> call(IncomeModel income) async {
    return await repository.deleteIncome(income);
  }
}
