import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';

class GetAllCategoryBudgetsUseCase {
  final CategoryBudgetRepository repository;
  GetAllCategoryBudgetsUseCase(this.repository);

  Future<Either<Failure, List<CategoryBudgetEntity>>> call() async {
    return repository.getBudgets();
  }
}
