import 'package:get/get.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class CurrentUser {
  factory CurrentUser() => CurrentUser._internal();
  CurrentUser._internal();

  static UserModel? _currentUser;

  static UserModel? get user => _currentUser;

  static bool get isUserLoggedIn {
    try {
      return Get.find<SharedPreferencesService>().isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  static String get token => Get.find<SharedPreferencesService>().token;

  static void initializeUser() {
    Get.find<SharedPreferencesService>();
    Get.find<SharedPreferencesService>().token;
  }
}
