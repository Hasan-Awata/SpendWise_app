import 'package:spendwise/features/auth/data/models/user_dto.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

abstract class UserRepository {
  Future<void> registerLocal(UserModel user);
  Future<UserModel> register(UserDto user);
  Future<UserModel> logIn(String userName, String password);
  Future<void> logOut();
  Future<UserModel?> getUser();
}
