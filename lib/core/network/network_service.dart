import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi)) {
      _runSyncTasks();
    }
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }

  Future<Either<Failure, T>> executeWithSync<T>({
    required Future<T> Function() remoteTask,
    required Future<void> Function(bool isSynced) localTask,
    required T localData,
  }) async {
    try {
      if (await isConnected) {
        try {
          final result = await remoteTask();
          await localTask(true);
          return Right(result);
        } catch (e) {
          return Left(ServerFailure("Server Error"));
        }
      } else {
        await localTask(false);
        return Right(localData);
      }
    } catch (e) {
      return Left(CacheFailure("Local Storage Error"));
    }
  }

  // // Correction for _runSyncTasks
  Future<void> _runSyncTasks() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // استدعاء الدوال بشكل مباشر ومنفصل لتجنب مشاكل النوع (Type Inference)
      Get.find<WalletsListController>().runBackgroundSync();
      Get.find<TagViewController>().runBackgroundSync();
      Get.find<IncomesListController>().runBackgroundSync();
      Get.find<ExpensesListController>().runBackgroundSync();
    } catch (e) {
      print("Sync Error: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<Either<Failure, T>> saveLocalAndSync<T>({
    required Future<void> Function() localSave,
    required Future<T> Function() remoteSave,
    required Future<void> Function(T remote) onSyncSuccess,
    required T localResult,
  }) async {
    try {
      // 1️⃣ Save local first (must succeed)
      await localSave();

      // 2️⃣ If no internet → success local only
      final connected = await isConnected;
      if (!connected) {
        return Right(localResult);
      }

      // 3️⃣ Try remote sync
      try {
        final remote = await remoteSave();
        await onSyncSuccess(remote);
        return Right(remote);
      } catch (e) {
        // local success but remote failed → still success
        return Right(localResult);
      }
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
