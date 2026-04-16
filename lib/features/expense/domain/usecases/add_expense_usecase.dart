// // Contract: features/expense/domain/usecases/add_expense_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';

class AddExpenseUsecase {
  final ExpenseRepository repository;
  AddExpenseUsecase(this.repository);

  Future<Either<Failure, Unit>> call(ExpenseModel expense) async {
    return await repository.addExpense(expense);
  }
}
