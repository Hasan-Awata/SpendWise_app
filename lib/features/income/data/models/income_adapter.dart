import 'package:hive/hive.dart';

import 'income_model.dart';

class IncomeAdapter extends TypeAdapter<IncomeModel> {
  @override
  final typeId = 1;

  @override
  IncomeModel read(BinaryReader reader) {
    return IncomeModel.fromLocal(reader.read());
  }

  @override
  void write(BinaryWriter writer, IncomeModel obj) {
    writer.write(obj.toLocal());
  }
}
