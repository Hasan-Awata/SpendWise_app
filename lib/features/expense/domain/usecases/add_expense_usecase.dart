// // Contract: features/expense/domain/usecases/add_expense_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';

class AddExpenseUsecase {
  final ExpenseRepository repository;
  AddExpenseUsecase(this.repository);

  Future<Either<Failure, String>> call(ExpenseEntity expense) async {
    return await repository.addExpense(expense);
  }
}
