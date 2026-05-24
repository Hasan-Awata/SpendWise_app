import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class IncomeRepository {
  Future<Either<Failure, String>> addIncome(IncomeEntity income);
  Future<Either<Failure, PagedResponse<IncomeEntity>>> getIncomes(
    int? userId,
    PageRequest page,
  );

  // Future<Either<Failure, List<IncomeEntity>>> getAllIncomesLocal();
  Future<Either<Failure, Unit>> deleteIncome(IncomeEntity income);
  Future<Either<Failure, Unit>> updateIncome(IncomeEntity income);
}
