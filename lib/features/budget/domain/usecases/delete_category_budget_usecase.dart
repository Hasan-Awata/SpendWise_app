import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';

class DeleteCategoryBudgetUseCase {
  final CategoryBudgetRepository repository;

  DeleteCategoryBudgetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(CategoryBudgetEntity budget) async {
    return await repository.deleteBudget(budget);
  }
}
