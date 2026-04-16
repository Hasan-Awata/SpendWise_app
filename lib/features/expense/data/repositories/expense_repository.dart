import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, Unit>> addExpense(ExpenseModel expense);

  Future<Either<Failure, PagedResponse<ExpenseModel>>> getExpenses(
    int? userId,
    PageRequest page,
  );

  Future<Either<Failure, Unit>> deleteExpense(ExpenseModel expense);
  Future<Either<Failure, Unit>> updateExpense(ExpenseModel expense);
  Future<Either<Failure, Unit>> syncPendingExpenses();
  Future<Either<Failure, List<ExpenseModel>>> getAllExpensesLocal();
}
