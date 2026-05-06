// // تعليق: حالة استخدام تحديث بيانات هدف ادخار موجود (مثل تعديل المبلغ الموفر حالياً)
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';

class UpdateSavingGoalUseCase {
  final SavingGoalRepository repository;

  UpdateSavingGoalUseCase(this.repository);

  Future<Either<Failure, Unit>> call(SavingGoalModel goal) async {
    return await repository.updateSavingGoal(goal);
  }
}
