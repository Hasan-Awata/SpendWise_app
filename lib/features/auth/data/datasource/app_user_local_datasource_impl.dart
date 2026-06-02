import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/helper_function.dart' show HelperFunction;
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository_impl.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/transaction/data/models/transaction_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class AppUserLocalDatasourceImpl extends GetxService
    implements AppUserLocalDatasource {
  final Isar isar;
  AppUserLocalDatasourceImpl(this.isar);

  final RxBool _isLoggingOut = false.obs;

  @override
  bool get isLoggingOut => _isLoggingOut.value;
  // SAVE USER
  // =========================
  @override
  Future<void> registerLocal(UserModel user) async {
    try {
      await isar.writeTxn(() async {
        // حذف المستخدم القديم
        await isar.userModels.clear();

        // حفظ المستخدم الجديد
        await isar.userModels.put(user);
      });

      // تحديث CurrentUser فقط
      CurrentUser.update(user);

      print("✅ User saved locally");
    } catch (e) {
      print("❌ Error saving user locally => $e");
      rethrow;
    }
  }

  // =========================
  // GET USER
  // =========================
  @override
  Future<UserModel?> getUser() async {
    try {
      return await isar.userModels.where().findFirst();
    } catch (e) {
      print("❌ Error fetching user => $e");
      return null;
    }
  }

  // =========================
  // GET USER ID
  // =========================
  @override
  Future<int?> getUserId() async {
    try {
      // المصدر الأساسي أصبح CurrentUser
      if (CurrentUser.userId != null) {
        return CurrentUser.userId;
      }

      final user = await getUser();

      if (user != null) {
        CurrentUser.update(user);

        return user.userId;
      }

      return null;
    } catch (e) {
      print("❌ Error getting user id => $e");
      return null;
    }
  }

  @override
  Future<void> logOut({bool silent = false}) async {
    try {
      await isar.writeTxn(() async {
        await isar.userModels.clear();
      });
      await CurrentUser.clear();

      // 2. استخدام Get.offAll للتأكد من مسح الـ Stack
      if (Get.currentRoute != Routes.LOGIN) {
        await Get.offAllNamed(Routes.LOGIN);
      }

      // 3. تأجيل الـ SnackBar لضمان أنها ستظهر في سياق الشاشة الجديدة
      if (!silent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          HelperFunction.showSnackBar(
            "تنبيه",
            "انتهت الجلسة، يرجى تسجيل الدخول",
          );
        });
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.userModels.clear();
      await isar.walletModels.clear();
      await isar.expenseModels.clear();
      await isar.incomeModels.clear();
      await isar.tagModels.clear();
      await isar.categoryBudgetModels.clear();
      await isar.savingGoalModels.clear();
      await isar.transactionModels.clear();
    });
    // تصفير المزامنة
    await SyncQueueRepositoryImpl(isar).clearQueue();
  }

  // =========================
  // FULL RESET
  // =========================
  Future<void> resetAppCompletely() async {
    try {
      print("🧹 Starting full reset...");

      await isar.writeTxn(() async {
        await isar.clear();
      });

      await CurrentUser.clear();

      await Get.offAllNamed(Routes.INITIAL);

      print("✅ Full reset completed");
    } catch (e) {
      print("❌ Full reset error => $e");
    }
  }
}
