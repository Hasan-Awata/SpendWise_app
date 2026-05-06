import 'package:hive/hive.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

class SavingGoalAdapter extends TypeAdapter<SavingGoalModel> {
  @override
  final typeId = 7;

  @override
  SavingGoalModel read(BinaryReader reader) {
    return SavingGoalModel.fromLocal(reader.read());
  }

  @override
  void write(BinaryWriter writer, SavingGoalModel obj) {
    writer.write(obj.toLocal());
  }
}
