import 'package:hive/hive.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import '../models/saving_goal_model.dart';

class SavingGoalLocalDatasourceImpl implements SavingGoalLocalDatasource {
  static const String _boxName = 'SAVING_GOALS';
  static const String _goalKey = 'goal_key';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    } else {
      return await Hive.openBox(_boxName);
    }
  }

  @override
  Future<List<SavingGoalModel>> getAllGoalsLocal() async {
    final box = await _getBox();
    final data = box.get(_goalKey);
    return data != null ? List<SavingGoalModel>.from(data) : [];
  }

  @override
  Future<void> updateGoalLocal(SavingGoalModel goal) async {
    final box = await _getBox();
    List<SavingGoalModel> goals = await getAllGoalsLocal();

    int index = goals.indexWhere(
      (g) =>
          (goal.goalId != null && g.goalId == goal.goalId) ||
          (g.localId == goal.localId),
    );

    if (index != -1) {
      goals[index] = goal;
    } else {
      goals.insert(0, goal);
    }

    await box.put(_goalKey, goals);
  }

  @override
  Future<void> deleteGoalLocal(String localId) async {
    final box = await _getBox();
    List<SavingGoalModel> goals = await getAllGoalsLocal();

    goals.removeWhere((g) => g.localId == localId);

    await box.put(_goalKey, goals);
  }
}
