import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class CurrentUser {
  // تصميم Singleton لمنع تكرار النسخ في الذاكرة
  factory CurrentUser() => CurrentUser._internal();
  CurrentUser._internal();

  static UserModel? _currentUser;

  /// الوصول المباشر لكائن المستخدم
  static UserModel? get user => _currentUser;

  /// جلب المعرف بشكل سريع (من الكاش)
  static int? get userId {
    try {
      final userSource = Get.find<AppUserLocalDatasource>();
      // نستخدم الـ Getter المباشر المتاح في الـ Implementation لسرعة الوصول
      return (userSource as AppUserLocalDatasourceImpl).currentUserId;
    } catch (e) {
      return _currentUser?.userId;
    }
  }

  /// التحقق مما إذا كان المستخدم مسجل دخوله حالياً
  static bool get isUserLoggedIn {
    try {
      final userSource = Get.find<AppUserLocalDatasource>();

      return (userSource as AppUserLocalDatasourceImpl).currentUserId != null;
    } catch (e) {
      return _currentUser != null;
    }
  }

  /// تهيئة بيانات المستخدم عند بداية تشغيل التطبيق
  static Future<void> initializeUser() async {
    try {
      final userSource = Get.find<AppUserLocalDatasource>();
      userSource.init();
      final user = await userSource.getUser();

      _currentUser = user;

      if (user != null) {
        print("👤 CurrentUser Synced: ${user.userName} (ID: ${user.userId})");
      } else {
        print("👤 CurrentUser: No local user session found.");
      }
    } catch (e) {
      print("⚠️ Critical Error initializing CurrentUser: $e");
    }
  }

  /// تحديث الذاكرة المؤقتة (عند تحديث البيانات من السيرفر أو تعديل البروفايل)
  static void updateCache(UserModel? user) {
    _currentUser = user;
    print("🔄 CurrentUser Cache Updated.");
  }

  /// الحصول على التوكن بشكل سريع لإضافته لطلبات الـ API
  static String get token => _currentUser?.token ?? "";
}
