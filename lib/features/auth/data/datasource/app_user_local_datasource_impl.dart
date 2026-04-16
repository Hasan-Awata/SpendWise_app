import 'package:flutter/foundation.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';

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

  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      await _box.put(_userKey, user);
      _cachedUserId = user.userId;
    } catch (e) {
      throw Exception("Failed to save user data locally: $e");
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

  // دالة إضافية للوصول المباشر (Synchronous) بدون await
  int? get currentUserId => _cachedUserId;
  // Logic: core/utils/database_helper.dart

  Future<void> resetAppCompletely() async {
    try {
      clear();
      IncomeLocalDataSourceImpl().clear();
      WalletLocalDatasourceImpl().clearWallets();
      TagLocalDatasourceImpl().clear();
      ExpenseLocalDataSourceImpl().clear();

      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.clear();

      HelperFunction.showSnackBar("نجاح", "تم تسجيل الخروج وتصفير البيانات");

      await Get.putAsync(
        () => SharedPreferencesService().init(),
        permanent: true,
      );

      Get.offAllNamed(Routes.INITIAL);
    } catch (e) {
      debugPrint("❌ Error during force logout: $e");
      // إذا فشل كل شيء، انتقل للبداية كحل أخير
      Get.offAllNamed(Routes.INITIAL);
    }
  }

  @override
  Future<void> clear() async {
    await _box.delete(_userKey);
  }
}
