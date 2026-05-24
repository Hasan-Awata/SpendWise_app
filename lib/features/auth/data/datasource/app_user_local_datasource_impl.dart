import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/helper_function.dart' show HelperFunction;
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository_impl.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class AppUserLocalDatasourceImpl extends GetxService
    implements AppUserLocalDatasource {
  final Isar isar;

  int? _cachedUserId;

  AppUserLocalDatasourceImpl(this.isar);

  @override
  Future<void> init() async {
    try {
      final user = await getUser();

      _cachedUserId = user?.userId;

      print("✅ AppUserLocalDatasource Initialized => $_cachedUserId");
    } catch (e) {
      print("❌ AppUserLocalDatasource Init Error => $e");
    }
  }

  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      await isar.writeTxn(() async {
        // حذف أي مستخدم سابق
        await isar.userModels.clear();

        // حفظ المستخدم الجديد
        await isar.userModels.put(user);
      });

      _cachedUserId = user.userId;

      print("✅ User saved locally");
    } catch (e) {
      print("❌ Error saving user locally => $e");
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return await isar.userModels.where().findFirst();
    } catch (e) {
      print("❌ Error fetching user => $e");
      return null;
    }
  }

  @override
  Future<int?> getUserId() async {
    try {
      // أولوية للكاش
      if (_cachedUserId != null) {
        return _cachedUserId;
      }

      final user = await getUser();

      if (user != null) {
        _cachedUserId = user.userId;
        return user.userId;
      }

      return null;
    } catch (e) {
      print("❌ Error getting user id => $e");
      return null;
    }
  }

  int? get currentUserId => _cachedUserId;

  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        // 1. مسح بيانات المستخدم الحالي
        await isar.userModels.clear();

        await isar.walletModels.clear();
        await isar.expenseModels.clear();
        await isar.incomeModels.clear();
        await isar.tagModels.clear();
        await isar.categoryBudgetModels.clear();
      });

      _cachedUserId = null;

      // 3. تصفير طابور المزامنة بأمان
      await SyncQueueRepositoryImpl(InitIsar.isar!).clearQueue();

      print("✅ Local user and wallets cleared safely");
    } catch (e) {
      print("❌ Error clearing local user data => $e");
    }
  }

  @override
  Future<void> logOut() async {
    try {
      print("🧹 Starting logout process...");
      await clear();

      // تصفير بيانات المستخدم الحالية
      CurrentUser.clear();

      // حذف الـ Controllers فقط
      final keys = Get.keys.keys.toList();

      for (final key in keys) {
        try {
          if (Get.isRegistered(tag: key.toString())) {
            await Get.delete(tag: key.toString(), force: false);
          }
        } catch (_) {}
      }

      HelperFunction.showSnackBar("Success", "Logged out successfully");
      await Get.offAllNamed(Routes.INITIAL);
      print("✅ Logout completed");
    } catch (e) {
      print("❌ Logout Error => $e");

      Get.offAllNamed(Routes.INITIAL);
    }
  }

  Future<void> resetAppCompletely() async {
    try {
      print("🧹 Starting full reset...");

      await isar.writeTxn(() async {
        await isar.clear();
      });

      _cachedUserId = null;

      CurrentUser.clear();

      Get.offAllNamed(Routes.INITIAL);

      print("✅ Full reset completed");
    } catch (e) {
      print("❌ Full reset error => $e");
    }
  }
}
