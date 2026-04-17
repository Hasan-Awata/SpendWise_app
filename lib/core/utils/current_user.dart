import 'package:get/get.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class CurrentUser {
  factory CurrentUser() => CurrentUser._internal();
  CurrentUser._internal();

  static UserModel? _currentUser;

  static String? _token;

  static bool get isUserLoggedIn {
    try {
      return Get.find<SharedPreferencesService>().isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  static UserModel? get user => _currentUser;

  static String get token => _token ?? "noToken";

  static void initializeUser() async {
    final user = await AppUserLocalDatasourceImpl().getUser();
    final pref = Get.find<SharedPreferencesService>();

    _currentUser = user;
    _token = pref.token;
  }
}
