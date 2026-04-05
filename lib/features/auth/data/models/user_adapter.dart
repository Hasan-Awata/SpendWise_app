import 'package:hive/hive.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class UserAdapter extends TypeAdapter<UserModel> {
  @override
  final typeId = 2;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel.fromJson(reader.read());
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.toJson());
  }
}
