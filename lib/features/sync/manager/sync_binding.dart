// تعليق: حقن وإعداد مستودع ومحرك مزامنة أهداف التوفير (SavingGoalSyncRepository) داخل ملف الـ Bindings لتفعيل المزامنة التلقائية عبر طابور المزامنة
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_local_datasource.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/presentation/bindings/category_budget_binding.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/presentation/bindings/expense_binding.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource.dart';
import 'package:spendwise/features/savings_goals/presentation/bindings/saving_goal_binding.dart';
import 'package:spendwise/features/sync/manager/sync_engine.dart';
import 'package:spendwise/features/sync/manager/sync_manager.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/sync/repository/category_budget_sync_repository.dart';
import 'package:spendwise/features/sync/repository/expense_sync_reposiory.dart';
import 'package:spendwise/features/sync/repository/income_sync_repository.dart';
import 'package:spendwise/features/sync/repository/saving_goal_sync_repository.dart';
import 'package:spendwise/features/sync/repository/tag_sync_repository.dart';
import 'package:spendwise/features/sync/repository/wallet_sync_repository.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    if (kDebugMode) {
      print("Initializing Sync Bindings...");
    }

    // =========================================================
    // Repositories
    // =========================================================
    WalletBinding().dependencies();
    Get.put(
      WalletSyncRepository(
        local: Get.find<WalletLocalDatasource>(),
        remote: Get.find<WalletRemoteDatasource>(),
      ),
      permanent: true,
    );
    TagBinding().dependencies();

    Get.put(
      TagSyncRepository(
        local: Get.find<TagLocalDatasource>(),
        remote: Get.find<TagRemoteDatasource>(),
      ),
      permanent: true,
    );

    IncomeBinding().dependencies();
    Get.put(
      IncomeSyncRepository(
        local: Get.find<IncomeLocalDataSource>(),
        remote: Get.find<IncomeRemoteDatasource>(),
      ),
      permanent: true,
    );

    ExpenseBinding().dependencies();
    Get.put(
      ExpenseSyncRepository(
        local: Get.find<ExpenseLocalDataSource>(),
        remote: Get.find<ExpenseRemoteDataSource>(),
      ),
      permanent: true,
    );

    CategoryBudgetBinding().dependencies();
    Get.put(
      CategoryBudgetSyncRepository(
        local: Get.find<CategoryBudgetLocalDatasource>(),
        remote: Get.find<CategoryBudgetRemoteDatasource>(),
      ),
      permanent: true,
    );
    SavingGoalBinding().dependencies();
    Get.put(
      SavingGoalSyncRepository(
        local: Get.find<SavingGoalLocalDataSource>(),
        remote: Get.find<SavingGoalRemoteDatasource>(),
      ),
      permanent: true,
    );

    // =========================================================
    // Engines
    // =========================================================
    final networkService = Get.find<NetworkService>();
    final queueRepo = Get.find<SyncQueueRepository>();

    final syncManager = SyncManager([
      SyncEngine(
        repository: Get.find<WalletSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "wallet",
      ),
      SyncEngine(
        repository: Get.find<TagSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "tag",
      ),
      SyncEngine(
        repository: Get.find<IncomeSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "income",
      ),
      SyncEngine(
        repository: Get.find<ExpenseSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "expense",
      ),
      SyncEngine(
        repository: Get.find<CategoryBudgetSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "category_budget",
      ),
      SyncEngine(
        repository: Get.find<SavingGoalSyncRepository>(),
        network: networkService,
        queueRepository: queueRepo,
        table: "saving_goal",
      ),
    ]);

    Get.put(syncManager, permanent: true);

    // =========================================================
    // ONLY ONE SOURCE OF SYNC: ONLINE TRIGGER
    // =========================================================
    bool isSyncingAll = false;

    ever(networkService.isOnline, (bool isOnline) async {
      if (!isOnline || isSyncingAll) return;

      try {
        isSyncingAll = true;

        if (kDebugMode) {
          print("🌐 Internet detected → SyncAll started");
        }

        await syncManager.syncAll();
      } catch (e) {
        if (kDebugMode) {
          print("SyncAll Error: $e");
        }
      } finally {
        isSyncingAll = false;
      }
    });

    // =========================================================
    // Initial sync only
    // =========================================================
    Future.microtask(() async {
      if (networkService.isOnline.value) {
        await syncManager.syncAll();
      }
    });
  }
}
