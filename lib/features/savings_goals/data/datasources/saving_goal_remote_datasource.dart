// تعليق: تحديث واجهة مصدر البيانات الخارجي لأهداف التوفير لتتوافق مع التعديلات الجديدة بجعل دالة جلب البيانات تعيد كائناً قابلاً للإلغاء (Nullable) كباقي المصادر الموحدة في التطبيق
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import '../models/saving_goal_model.dart';

abstract class SavingGoalRemoteDatasource {
  Future<PagedResponse<SavingGoalModel>?> getAllUserGoals(
    int userId,
    PageRequest page,
  );
  Future<SavingGoalModel?> getGoalById(int goalId);
  Future<SavingGoalModel> addGoal(SavingGoalModel goal);
  Future<SavingGoalModel> updateGoal(SavingGoalModel goal);
  Future<bool> deleteGoal(int goalId);
  Future<List<SavingGoalModel>> getAchievedGoals(int userId);
}
