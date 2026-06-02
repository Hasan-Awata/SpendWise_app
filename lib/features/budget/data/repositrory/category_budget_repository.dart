import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';

abstract class CategoryBudgetRepository {
  Future<Either<Failure, List<CategoryBudgetEntity>>> getBudgets();

  Future<Either<Failure, String>> addBudget(CategoryBudgetEntity budget);

  Future<Either<Failure, Unit>> updateBudget(CategoryBudgetEntity budget);

  Future<Either<Failure, Unit>> deleteBudget(CategoryBudgetEntity budget);

  Future<Either<Failure, CategoryBudgetEntity?>> getActiveBudgetForCategory(
    int categoryId,
  );
}
