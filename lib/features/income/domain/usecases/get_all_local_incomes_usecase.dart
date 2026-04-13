import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';

class GetAllLocalIncomesUsecase {
  final IncomeRepository repository;

  GetAllLocalIncomesUsecase(this.repository);

  Future<Either<Failure, List<IncomeModel>>> call() =>
      repository.getAllIncomesLocal();
}
