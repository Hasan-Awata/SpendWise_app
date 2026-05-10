// [تعليق: تطبيق الـ Local Datasource باستخدام Isar مع حقن التبعيات عبر المشيد لضمان الأداء العالي]
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

class AppUserLocalDatasourceImpl extends GetxService
    implements AppUserLocalDatasource {
  // نسخة Isar الممررة عبر المشيد (Constructor Injection)
  final Isar isar;

  // مخزن مؤقت للمعرف لضمان الوصول اللحظي دون الحاجة لانتظار القرص الصلب
  int? _cachedUserId;

  // المشيد الجديد الذي يستقبل محرك Isar
  AppUserLocalDatasourceImpl(this.isar);

  @override
  Future<void> init() async {
    try {
      final user = await getUser();
      _cachedUserId = user?.userId;
      print("✅ AppUser Service Initialized. Cached ID: $_cachedUserId");
    } catch (e) {
      throw Exception("Failed to initialize user local storage: $e");
    }
  }

  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      // تنفيذ عملية الكتابة داخل Transaction لضمان سلامة البيانات
      await isar.writeTxn(() async {
        await isar.userModels.put(user);
      });

      _cachedUserId = user.userId;
      print("✅ User saved to Isar successfully");
    } catch (e) {
      print("❌ Error saving user to Isar: $e");
    }
  }

  @override
  Future<UserModel?> getUser() async {
    // استرجاع أول سجل مستخدم متاح في المجموعة
    return await isar.userModels.where().findFirst();
  }

  @override
  Future<int?> getUserId() async {
    // الأولوية دائماً للقيمة الموجودة في الـ RAM
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }

    // محاولة أخيرة من قاعدة البيانات في حال فقدان الكاش
    final user = await getUser();
    if (user != null) {
      _cachedUserId = user.userId;
      return user.userId;
    }
    return null;
  }

  // Getter للوصول المباشر للمعرف دون await
  int? get currentUserId => _cachedUserId;

  @override
  Future<void> logOut() async {
    try {
      await resetAppCompletely();
    } catch (e) {
      throw Exception("Failed to clear local user session: $e");
    }
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.userModels.clear();
    });
    _cachedUserId = null;
  }

  // دالة المسح الشامل لإعادة التطبيق لحالة المصنع
  Future<void> resetAppCompletely() async {
    try {
      print("🧹 Starting Global System Reset...");

      await isar.writeTxn(() async {
        await isar.clear();
      });

      // 2. مسح SharedPreferences (الإعدادات البسيطة)
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.clear();

      // 3. تطهير الذاكرة من كافة الـ Controllers
      await Get.deleteAll(force: true);

      Get.put(isar, permanent: true);

      // 5. التوجه لصفحة البداية وتصفير الـ Navigation Stack
      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
      print("❌ Reset Error: $e");
      Get.offAllNamed(Routes.INITIAL);
    }
  }
}
