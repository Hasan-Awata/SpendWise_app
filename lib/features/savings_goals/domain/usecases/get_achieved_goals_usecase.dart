// // تعليق: حالة استخدام جلب قائمة الأهداف التي تم تحقيق مبالغها بنجاح
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';

class GetAchievedGoalsUseCase {
  final SavingGoalRepository repository;

  GetAchievedGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingGoalModel>>> call(int userId) async {
    return await repository.getAchievedGoals(userId);
  }
}
