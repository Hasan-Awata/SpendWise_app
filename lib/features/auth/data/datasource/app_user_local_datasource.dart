import 'package:spendwise/features/auth/data/models/user_model.dart';

abstract class AppUserLocalDatasource {
  Future<void> init();
  Future<void> registerLocal(UserModel user);
  Future<UserModel?> getUser();
  Future<void> logOut();
}
