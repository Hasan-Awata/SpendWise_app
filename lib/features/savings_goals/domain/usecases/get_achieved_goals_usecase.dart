// // تعليق: حالة استخدام جلب قائمة الأهداف التي تم تحقيق مبالغها بنجاح
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

class GetAchievedGoalsUseCase {
  final SavingGoalRepository repository;

  GetAchievedGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingGoalEntity>>> call(int userId) async {
    return await repository.getAchievedGoals(userId);
  }
}
