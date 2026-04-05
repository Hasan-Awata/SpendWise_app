import '../models/user_dto.dart';
import '../models/user_model.dart';

abstract class AppUserRemoteDatasource {
  Future<UserModel> register(UserDto userDto);
  Future<UserModel> logIn(String userName, String password);
  Future<void> logOut();
}
