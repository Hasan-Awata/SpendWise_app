// // تعليق: حالة استخدام حذف هدف ادخار من النظام المحلي والبعيد
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

class DeleteSavingGoalUseCase {
  final SavingGoalRepository repository;

  DeleteSavingGoalUseCase(this.repository);

  Future<Either<Failure, Unit>> call(SavingGoalEntity goal) async {
    return await repository.deleteSavingGoal(goal);
  }
}
