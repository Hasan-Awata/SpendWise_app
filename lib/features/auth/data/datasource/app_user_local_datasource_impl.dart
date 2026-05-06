import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';

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
      await _box.put('current_user', user);

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

  // // استخدام أسلوب المسح المتسلسل لضمان عدم تداخل العمليات
  Future<void> resetAppCompletely() async {
    try {
      print("🧹 Starting Safe Reset...");

      // 1. مسح البيانات المحلية أولاً (قبل حذف الـ Controllers)
      await _clearAllData();

      // 2. مسح SharedPreferences
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.clear();
      print("💾 SharedPrefs Cleared");

      // 3. حذف كافة المتحكمات من الذاكرة تماماً
      // ملاحظة: force: true ضروري للمتحكمات التي تحمل صفة permanent
      await Get.deleteAll(force: true);
      print("🧠 GetX Controllers Purged");

      // 4. إغلاق Hive نهائياً (إذا كنت تنوي حذف الملفات من القرص)
      await Hive.close();
      // await Hive.deleteFromDisk(); // حذر: هذا يحذف كل شيء بما في ذلك الإعدادات

      // 5. إعادة بناء الاعتمادات الأساسية فقط التي يحتاجها التطبيق للبدء
      await Get.putAsync(
        () => SharedPreferencesService().init(),
        permanent: true,
      );

      // 6. استخدام التوجيه الذي يضمن تفريغ مكدس الصفحات (Stack)
      // // التأكد من عدم بقاء أي صفحة قديمة في الذاكرة
      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
      print("❌ Reset Critical Error: $e");
      Get.offAllNamed(Routes.INITIAL);
    }
  }

  Future<void> _clearAllData() async {
    List<String> boxesToClear = [
      "CURRENTUSER",
      "MYINCOME",
      "MYEXPENSE",
      "TAG_BOX",
      "WALLET",
      "SAVING_GOALS",
    ];

    for (String boxName in boxesToClear) {
      // التحقق مما إذا كان الصندوق مفتوحاً أصلاً لتجنب الأخطاء
      var box = await Hive.openBox(boxName);
      await box.clear();
      // // تأكد من إغلاق الصندوق بعد مسحه لضمان كتابة التغييرات على القرص
      await box.close();
    }
    print("✅ All targeted boxes cleared and closed");
  }

  @override
  Future<void> clear() async {
    await _box.delete(_userKey);
  }
}
