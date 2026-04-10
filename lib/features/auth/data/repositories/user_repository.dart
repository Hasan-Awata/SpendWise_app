import 'package:spendwise/features/auth/data/models/signup_dto.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

abstract class UserRepository {
  Future<void> registerLocal(UserModel user);
  Future<UserModel> register(SignupParams params);
  Future<UserModel> logIn(LoginParams params);
  Future<void> logOut();
  Future<UserModel?> getUser();
  Future<int> getUserId();
}
