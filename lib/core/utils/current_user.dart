import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class CurrentUser {
  CurrentUser._();

  static UserModel? _user;

  static UserModel? get user => _user;

  static bool get isLoggedIn => _user != null;

  static int? get userId => _user?.userId;

  static String get token => _user?.token ?? "";

  static String get refreshToken => _user?.refreshToken ?? "";

  /// تحميل المستخدم من التخزين المحلي عند تشغيل التطبيق
  static Future<void> initialize() async {
    try {
      final datasource = Get.find<AppUserLocalDatasource>();

      _user = await datasource.getUser();

      print("✅ CurrentUser initialized => ${_user?.userName}");
    } catch (e) {
      print("❌ CurrentUser initialize error => $e");
    }
  }

  /// حفظ المستخدم في الذاكرة والتخزين المحلي
  static Future<void> save(UserModel user) async {
    try {
      final datasource = Get.find<AppUserLocalDatasource>();

      await datasource.registerLocal(user);

      _user = user;

      print("✅ CurrentUser saved");
    } catch (e) {
      print("❌ CurrentUser save error => $e");
    }
  }

  /// تحديث الكاش فقط
  static void update(UserModel? user) {
    _user = user;
  }

  /// حذف الجلسة
  static Future<void> clear() async {
    try {
      final datasource = Get.find<AppUserLocalDatasource>();

      await datasource.clear();

      _user = null;

      print("✅ CurrentUser cleared");
    } catch (e) {
      print("❌ CurrentUser clear error => $e");
    }
  }
}
