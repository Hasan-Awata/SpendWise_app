import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class AddIncomeUsecase {
  final IncomeRepository repository;

  AddIncomeUsecase(this.repository);

  Future<Either<Failure, IncomeModel>> call(IncomeModel income) async {
    //AddIncomeUsecase حقن النسخة الصحيحة داخل الBinding
    return await repository.addIncome(income);
  }
}
