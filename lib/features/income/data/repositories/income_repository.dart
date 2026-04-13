import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class IncomeRepository {
  Future<Either<Failure, Unit>> addIncome(IncomeModel income);
  Future<Either<Failure, PagedResponse<IncomeModel>>> getIncomes(
    int? userId,
    PageRequest page,
  );
  Future<Either<Failure, List<IncomeModel>>> getAllIncomesLocal();
  Future<Either<Failure, Unit>> deleteIncome(int incomeId);
  Future<Either<Failure, Unit>> updateIncome(int incomeId, IncomeModel income);
  Future<Either<Failure, Unit>> syncPendingIncomes(); // مضافة للمزامنة اليدوية
}
