import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

abstract class SavingGoalLocalDataSource {
  Future<void> saveSavingGoals(List<SavingGoalModel> savingGoals);
  Future<void> addSavingGoal(SavingGoalModel savingGoal);
  Future<List<SavingGoalModel>> getSavingGoals();
  SavingGoalModel? getSavingGoalByServerId(int? walletId);
  Future<SavingGoalModel?> getSavingGoal(String localId);
  Future<SavingGoalModel?> getSavingGoalByIsarId(int isarId);
  Future<void> deleteSavingGoal(SavingGoalModel savingGoal);
  Future<void> updateSavingGoal(SavingGoalModel savingGoal);
  Future<void> saveOrUpdateRemoteSavingGoal(SavingGoalModel remoteSavingGoal);
  Future<bool> checkIfSavingGoalExists(String localId);
  Future<bool> checkIfSavingGoalExistsById(int id);
  Future<void> clear();
}
