import 'package:hive/hive.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';

import 'package:spendwise/features/auth/data/models/user_model.dart';

class AppUserLocalDatasourceImpl implements AppUserLocalDatasource {
  static final AppUserLocalDatasourceImpl _instance =
      AppUserLocalDatasourceImpl._internal();
  AppUserLocalDatasourceImpl._internal();
  factory AppUserLocalDatasourceImpl() => _instance;

  static const String _boxName = 'CURRENTUSER';
  static const String _userKey = 'current_user';

  late Box _box;

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      throw Exception("Failed to initialize local storage: $e");
    }
  }

  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      await _box.put(_userKey, user);
    } catch (e) {
      throw Exception("Failed to save user data locally: $e");
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return _box.get(_userKey) as UserModel?;
    } catch (e) {
      throw Exception("Failed to retrieve user data: $e");
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _box.delete(_userKey);
    } catch (e) {
      throw Exception("Failed to clear local user session: $e");
    }
  }
}
