import 'package:spendwise/features/auth/data/models/user_model.dart';

abstract class AppUserLocalDatasource {
  Future<void> registerLocal(UserModel user);
  Future<void> logOut();
  bool get isLoggingOut;
  Future<UserModel?> getUser();
  Future<int?> getUserId();
  Future<void> clear();
}
