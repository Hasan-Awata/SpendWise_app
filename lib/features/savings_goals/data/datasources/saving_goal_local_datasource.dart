import '../models/saving_goal_model.dart';

abstract class SavingGoalLocalDatasource {
  Future<List<SavingGoalModel>> getAllGoalsLocal();

  Future<void> updateGoalLocal(SavingGoalModel goal);

  Future<void> deleteGoalLocal(String localId);
}
