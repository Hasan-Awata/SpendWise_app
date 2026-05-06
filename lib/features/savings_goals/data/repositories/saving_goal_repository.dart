// // تعليق: واجهة المستودع لتوحيد الوصول للبيانات بين المصدر المحلي والبعيد باستخدام Functional Error Handling
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import '../models/saving_goal_model.dart';

abstract class SavingGoalRepository {
  Future<Either<Failure, String>> addSavingGoal(SavingGoalModel goal);
  Future<Either<Failure, PagedResponse<SavingGoalModel>>> getMySavingGoals(
    int userId,
    PageRequest page,
  );
  Future<Either<Failure, Unit>> updateSavingGoal(SavingGoalModel goal);
  Future<Either<Failure, Unit>> deleteSavingGoal(SavingGoalModel goal);
  Future<Either<Failure, List<SavingGoalModel>>> getAchievedGoals(int userId);
  Future<Either<Failure, Unit>> syncPendingGoals();
}
