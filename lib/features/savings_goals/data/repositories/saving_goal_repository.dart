// // تعليق: واجهة المستودع لتوحيد الوصول للبيانات بين المصدر المحلي والبعيد باستخدام Functional Error Handling
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

abstract class SavingGoalRepository {
  Future<Either<Failure, String>> addSavingGoal(SavingGoalEntity goal);
  Future<Either<Failure, PagedResponse<SavingGoalEntity>>> getMySavingGoals(
    int userId,
    PageRequest page,
  );
  Future<Either<Failure, List<SavingGoalEntity>>> getAllSavingGoalLocal();
  Future<Either<Failure, Unit>> updateSavingGoal(SavingGoalEntity goal);
  Future<Either<Failure, Unit>> deleteSavingGoal(SavingGoalEntity goal);
  Future<Either<Failure, List<SavingGoalEntity>>> getAchievedGoals(int userId);
  Future<Either<Failure, Unit>> syncPendingGoals();
}
