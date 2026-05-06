// // تعليق: تعريف الواجهة لمصدر البيانات البعيد لضمان فصل المسؤوليات وسهولة الاختبار
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import '../models/saving_goal_model.dart';

abstract class SavingGoalRemoteDatasource {
  Future<PagedResponse<SavingGoalModel>> getAllUserGoals(
    int userId,
    PageRequest page,
  );
  Future<SavingGoalModel?> getGoalById(int goalId);
  Future<SavingGoalModel> addGoal(SavingGoalModel goal);
  Future<SavingGoalModel> updateGoal(SavingGoalModel goal);
  Future<bool> deleteGoal(int goalId);
  Future<List<SavingGoalModel>> getAchievedGoals(int userId);
}
