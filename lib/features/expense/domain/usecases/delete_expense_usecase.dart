import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';

class DeleteExpenseUsecase {
  final ExpenseRepository repository;
  DeleteExpenseUsecase(this.repository);

  Future<Either<Failure, Unit>> call(ExpenseModel expense) async {
    return await repository.deleteExpense(expense);
  }
}
