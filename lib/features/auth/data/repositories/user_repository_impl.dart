import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

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
  Future<UserModel> register(SignupParams params) async {
    final user = await appUserRemoteDatasource.register(params);
    await appUserLocalDatasource.registerLocal(user);
    return user;
  }

  @override
  Future<UserModel> logIn(LoginParams params) async {
    final user = await appUserRemoteDatasource.logIn(params);
    await appUserLocalDatasource.registerLocal(user);
    return user;
  }

  @override
  Future<void> logOut() async {
    await appUserRemoteDatasource.logOut();
    await appUserLocalDatasource.logOut();
  }

  @override
  Future<UserModel?> getUser() async {
    return await appUserLocalDatasource.getUser();
  }

  @override
  Future<int> getUserId() async {
    return await appUserLocalDatasource.getUserId();
  }
}
