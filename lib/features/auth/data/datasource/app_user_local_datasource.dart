import 'package:spendwise/features/auth/data/models/user_model.dart';

abstract class AppUserLocalDatasource {
  Future<void> init();
  Future<void> registerLocal(UserModel user);
  Future<void> logOut();
  Future<UserModel?> getUser();
  Future<int> getUserId();
}
