import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/data/repositrory/category_budget_repository.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';

class AddCategoryBudgetUseCase {
  final CategoryBudgetRepository repository;

  AddCategoryBudgetUseCase(this.repository);

  Future<Either<Failure, String>> call(CategoryBudgetEntity budgte) async {
    //AddCategoryBudgetUseCase  حقن النسخة الصحيحة داخل الBinding
    return await repository.addBudget(budgte);
  }
}
