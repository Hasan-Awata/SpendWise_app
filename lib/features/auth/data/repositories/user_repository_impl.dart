import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource.dart';

import 'package:spendwise/features/auth/data/models/user_dto.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AppUserLocalDatasource appUserLocalDatasource;
  final AppUserRemoteDatasource appUserRemoteDatasource;
  UserRepositoryImpl({
    required this.appUserLocalDatasource,
    required this.appUserRemoteDatasource,
  });

  //local
  @override
  Future<void> registerLocal(UserModel user) async {
    await appUserLocalDatasource.registerLocal(user);
  }

  @override
  Future<UserModel> register(UserDto userDto) async {
    return await appUserRemoteDatasource.register(userDto);
  }

  @override
  Future<UserModel> logIn(String userName, String password) async {
    return await appUserRemoteDatasource.logIn(userName, password);
  }

  @override
  Future<void> logOut() async {
    await appUserRemoteDatasource.logOut();
  }

  @override
  Future<UserModel?> getUser() async {
    return await appUserLocalDatasource.getUser();
  }
}
