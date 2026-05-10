import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';

class DeleteExpenseUsecase {
  final ExpenseRepository repository;
  DeleteExpenseUsecase(this.repository);

  Future<Either<Failure, Unit>> call(ExpenseEntity expense) async {
    return await repository.deleteExpense(expense);
  }
}
