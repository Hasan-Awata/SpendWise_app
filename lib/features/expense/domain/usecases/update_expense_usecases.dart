import 'package:dartz/dartz.dart' show Unit, Either;
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';

class UpdateExpenseUsecase {
  final ExpenseRepository repository;
  UpdateExpenseUsecase(this.repository);

  Future<Either<Failure, Unit>> call(ExpenseEntity expense) async {
    return await repository.updateExpense(expense);
  }
}
