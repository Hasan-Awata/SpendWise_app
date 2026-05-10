import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';

class AddIncomeUsecase {
  final IncomeRepository repository;

  AddIncomeUsecase(this.repository);

  Future<Either<Failure, String>> call(IncomeEntity income) async {
    //AddIncomeUsecase حقن النسخة الصحيحة داخل الBinding
    return await repository.addIncome(income);
  }
}
