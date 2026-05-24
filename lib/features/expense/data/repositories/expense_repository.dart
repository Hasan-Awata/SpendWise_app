import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, String>> addExpense(ExpenseEntity entity);

  Future<Either<Failure, PagedResponse<ExpenseEntity>>> getExpenses(
    int? userId,
    PageRequest page,
  );

  Future<Either<Failure, Unit>> deleteExpense(ExpenseEntity expense);
  Future<Either<Failure, Unit>> updateExpense(ExpenseEntity expense);
}
