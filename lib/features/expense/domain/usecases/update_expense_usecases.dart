import 'package:dartz/dartz.dart' show Unit, Either;
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';

class UpdateExpenseUsecase {
  final ExpenseRepository repository;
  UpdateExpenseUsecase(this.repository);

  Future<Either<Failure, Unit>> call(ExpenseModel expense) async {
    return await repository.updateExpense(expense);
  }
}
