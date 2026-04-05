import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

import '../models/user_model.dart';

abstract class AppUserRemoteDatasource {
  Future<UserModel> register(SignupParams params);
  Future<UserModel> logIn(LoginParams params);
  Future<void> logOut();
}
