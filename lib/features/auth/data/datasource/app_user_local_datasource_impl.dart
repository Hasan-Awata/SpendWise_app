import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/helper_function.dart';

class AppUserLocalDatasourceImpl extends GetxService
    implements AppUserLocalDatasource {
  static final AppUserLocalDatasourceImpl _instance =
      AppUserLocalDatasourceImpl._internal();
  AppUserLocalDatasourceImpl._internal();
  factory AppUserLocalDatasourceImpl() => _instance;

  static const String _boxName = 'CURRENTUSER';
  static const String _userKey = 'current_user';

  late Box _box;

  int? _cachedUserId;

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      // جلب المعرف وتخزينه في الذاكرة فور تشغيل التطبيق
      final user = _box.get(_userKey) as UserModel?;
      _cachedUserId = user?.userId;
    } catch (e) {
      throw Exception("Failed to initialize local storage: $e");
    }
  }

  // // تعليق: تحديث دالة الحفظ المحلي لتكون مقاومة لأخطاء الإغلاق المفاجئ (Offline-Safe)
  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      Box<UserModel> userBox;

      if (Hive.isBoxOpen('user_box')) {
        userBox = Hive.box<UserModel>('user_box');
      } else {
        print("📦 User box was closed during reset, re-opening...");
        userBox = await Hive.openBox<UserModel>('user_box');
      }

      await userBox.put('current_user', user);

      _cachedUserId = user.userId;

      print("✅ User data saved successfully to local storage");
    } catch (e) {
      print("❌ Critical Error in registerLocal: $e");
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await resetAppCompletely();
    } catch (e) {
      throw Exception("Failed to clear local user session: $e");
    }
  }

  @override
  Future<UserModel?> getUser() async {
    return _box.get(_userKey) as UserModel?;
  }

  // الآن هذه الدالة سريعة جداً لأنها تعيد القيمة من الذاكرة مباشرة
  @override
  Future<int> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }
    // محاولة أخيرة للقراءة من الـ Box إذا كانت الذاكرة فارغة
    final user = await getUser();
    if (user != null) {
      _cachedUserId = user.userId;
      return user.userId;
    }
    throw Exception("User not found");
  }

  int? get currentUserId => _cachedUserId;

  Future<void> resetAppCompletely() async {
    try {
      print("🧹 Starting Safe Reset...");

      Get.deleteAll(force: true);
      print("🧠 GetX Controllers Purged");

      _clearAllData();
      await Hive.close();
      print("📦 Hive Closed");

      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.clear();

      await Hive.deleteFromDisk();
      print("📂 Disk Purged");

      await Hive.initFlutter();

      await Get.putAsync(
        () => SharedPreferencesService().init(),
        permanent: true,
      );

      // 6. التوجيه لصفحة البداية
      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
      print("❌ Reset Critical Error: $e");
      Get.offAllNamed(Routes.INITIAL);
    }
  }

  Future<void> _clearAllData() async {
    // قائمة بالأسماء التي تريد حذفها
    List<String> boxesToClear = [
      "CURRENTUSER",
      "MYINCOME",
      "MYEXPENSE",
      "TAG_BOX",
      "WALLET",
    ];

    for (String boxName in boxesToClear) {
      // نفتح الـ Box ثم نمسح محتوياته، هذه الطريقة تعمل 100%
      var box = await Hive.openBox(boxName);
      await box.clear();
      // اختياري: إذا أردت حذف الملف نهائياً بعد التصفير
      // await box.deleteFromDisk();
    }
    print("✅ All local storage cleared successfully");
  }

  @override
  Future<void> clear() async {
    await _box.delete(_userKey);
  }
}
