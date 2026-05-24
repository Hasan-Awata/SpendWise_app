// =========================================================================
// ملف الـ Binding الخاص بالمزامنة بعد إضافة مستودعات ومحركات المزامنة لجميع الميزات
// =========================================================================

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/presentation/bindings/category_budget_binding.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/presentation/bindings/expense_binding.dart';
import 'package:spendwise/features/home/presentation/bindings/main_binding.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/sync/manager/sync_engine.dart';
import 'package:spendwise/features/sync/manager/sync_manager.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/sync/repository/category_budget_sync_repository.dart';
import 'package:spendwise/features/sync/repository/expense_sync_reposiory.dart';
import 'package:spendwise/features/sync/repository/income_sync_repository.dart';
import 'package:spendwise/features/sync/repository/tag_sync_repository.dart';
// استيراد مستودعات المزامنة (Sync Repositories)
import 'package:spendwise/features/sync/repository/wallet_sync_repository.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
// استيراد الـ Datasources اللازمة للحقن
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
// استيراد الـ Bindings الفرعية إذا كنت تفضل تشغيلها هنا
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    if (kDebugMode) {
      print("Initializing Sync Bindings for all features...");
    }

    WalletBinding().dependencies();
    MainBinding().dependencies();
    TagBinding().dependencies();
    IncomeBinding().dependencies();
    ExpenseBinding().dependencies();
    CategoryBudgetBinding().dependencies();

    Get.put<WalletSyncRepository>(
      WalletSyncRepository(
        local: Get.find<WalletLocalDatasource>(),
        remote: Get.find<WalletRemoteDatasource>(),
      ),
      permanent: true,
    );

    // Tag Sync Repo
    Get.put<TagSyncRepository>(
      TagSyncRepository(
        local: Get.find<TagLocalDatasource>(),
        remote: Get.find<TagRemoteDatasource>(),
      ),
      permanent: true,
    );

    // Income Sync Repo
    Get.put<IncomeSyncRepository>(
      IncomeSyncRepository(
        local: Get.find<IncomeLocalDataSource>(),
        remote: Get.find<IncomeRemoteDatasource>(),
      ),
      permanent: true,
    );

    // Expense Sync Repo
    Get.put<ExpenseSyncRepository>(
      ExpenseSyncRepository(
        local: Get.find<ExpenseLocalDataSource>(),
        remote: Get.find<ExpenseRemoteDataSource>(),
      ),
      permanent: true,
    );

    Get.put<CategoryBudgetSyncRepository>(
      CategoryBudgetSyncRepository(
        local: Get.find<CategoryBudgetLocalDatasource>(),
        remote: Get.find<CategoryBudgetRemoteDatasource>(),
      ),
      permanent: true,
    );
    // =========================================================================
    // 3. REGISTER ENGINES FOR EACH FEATURE
    // =========================================================================
    final networkService = Get.find<NetworkService>();
    final queueRepo = Get.find<SyncQueueRepository>();

    final walletEngine = SyncEngine(
      repository: Get.find<WalletSyncRepository>(),
      network: networkService,
      queueRepository: queueRepo,
      table: "wallet", // 🔥 تمرير اسم جدول المحافظ
    );

    final tagEngine = SyncEngine(
      repository: Get.find<TagSyncRepository>(),
      network: networkService,
      queueRepository: queueRepo,
      table: "tag", // 🔥 تمرير اسم جدول الأوسام
    );

    final incomeEngine = SyncEngine(
      repository: Get.find<IncomeSyncRepository>(),
      network: networkService,
      queueRepository: queueRepo,
      table: "income",
    );

    final expenseEngine = SyncEngine(
      repository: Get.find<ExpenseSyncRepository>(),
      network: networkService,
      queueRepository: queueRepo,
      table: "expense",
    );

    final categoryBudgetEngine = SyncEngine(
      repository: Get.find<CategoryBudgetSyncRepository>(),
      network: networkService,
      queueRepository: queueRepo,
      table: "category_budget",
    );
    final syncManager = SyncManager([
      walletEngine,
      tagEngine,
      incomeEngine,
      expenseEngine,
      categoryBudgetEngine,
    ]);

    Get.put<SyncManager>(syncManager, permanent: true);
    // =========================================================================
    // 5. LISTENERS & OBSERVERS (المحمية من الـ Loop)
    // =========================================================================
    bool isSyncingAll = false;

    // استخدام debounce أو شروط حماية متينة لحالة الإنترنت
    ever(networkService.isOnline, (bool isOnline) async {
      // نتحقق أن الإنترنت يعمل، وأن المحرك لا يقوم بمزامنة شاملة حالياً
      if (isOnline && !isSyncingAll) {
        try {
          isSyncingAll = true;
          await syncManager.syncAll();
        } catch (e) {
          print("🚨 SyncBinding: Error during syncAll: $e");
        } finally {
          isSyncingAll = false;
        }
      }
    });

    // مستمع الطابور للعنصر الأخير (تأكد من وجود نفس الحماية)
    bool isProcessingQueue = false;
    ever(queueRepo.queueVersion, (_) async {
      if (networkService.isOnline.value && !isProcessingQueue) {
        try {
          isProcessingQueue = true;

          await syncManager.syncLast();
        } catch (e) {
          print("🚨 SyncBinding: Error during syncLast: $e");
        } finally {
          isProcessingQueue = false;
        }
      }
    });

    Future.microtask(() async {
      if (networkService.isOnline.value) {
        await syncManager.syncAll();
      }
    });
  }
}
