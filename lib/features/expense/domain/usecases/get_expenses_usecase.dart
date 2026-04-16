// // Contract: features/expense/domain/usecases/get_expenses_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class GetExpensesUsecase {
  final ExpenseRepository repository;

  GetExpensesUsecase(this.repository);

  Future<Either<Failure, PagedResponse<ExpenseModel>>> call(
    int? userId,
    PageRequest pageRequest,
  ) async {
    return await repository.getExpenses(userId, pageRequest);
  }
}
