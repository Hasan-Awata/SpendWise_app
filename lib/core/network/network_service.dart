import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final bool _isSyncing = false;
  Timer? _debounceTimer;

  // =====================================================
  // CHECK REAL INTERNET (IMPORTANT FIX)
  // =====================================================
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // CONNECTIVITY HANDLER (IMPROVED)
  // =====================================================
  // void _updateConnectionStatus(List<ConnectivityResult> results) async {
  //   final isNetworkAvailable =
  //       results.contains(ConnectivityResult.mobile) ||
  //       results.contains(ConnectivityResult.wifi);

  //   if (!isNetworkAvailable) return;

  //   // 🔥 Debounce (منع تكرار التشغيل)
  //   _debounceTimer?.cancel();
  //   _debounceTimer = Timer(const Duration(seconds: 2), () async {
  //     final hasInternet = await _hasRealInternet();

  //     if (hasInternet) {
  //       _runSyncTasks();
  //     }
  //   });
  // }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    final network =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);

    if (!network) return false;

    return await _hasRealInternet();
  }

  // =====================================================
  // SYNC TASKS (IMPROVED STABILITY)
  // =====================================================
  // Future<void> _runSyncTasks() async {
  //   if (_isSyncing) return;

  //   final hasUser = CurrentUser.user != null;
  //   if (!hasUser) return;

  //   _isSyncing = true;

  //   try {
  //     await Future.delayed(const Duration(seconds: 1));
  //     // 🔥 يعطي وقت لاستقرار الشبكة

  //     if (Get.isRegistered<WalletsListController>()) {
  //       Get.find<WalletsListController>().runBackgroundSync();
  //     }

  //     if (Get.isRegistered<TagViewController>()) {
  //       Get.find<TagViewController>().runBackgroundSync();
  //     }

  //     if (Get.isRegistered<IncomesListController>()) {
  //       Get.find<IncomesListController>().runBackgroundSync();
  //     }

  //     // if (Get.isRegistered<ExpensesListController>()) {
  //     //   Get.find<ExpensesListController>().runBackgroundSync();
  //     // }
  //   } catch (e) {
  //     print("Sync Error: $e");
  //   } finally {
  //     _isSyncing = false;
  //   }
  // }

  // =====================================================
  // باقي الكود بدون تغيير
  // =====================================================

  Future<Either<Failure, T>> executeWithSync<T>({
    required Future<T> Function() remoteTask,
    required Future<void> Function(bool isSynced) localTask,
    required T localData,
  }) async {
    try {
      if (await isConnected) {
        final result = await remoteTask();
        await localTask(true);
        return Right(result);
      } else {
        await localTask(false);
        return Right(localData);
      }
    } catch (e) {
      return Left(CacheFailure("Local Storage Error"));
    }
  }

  Future<Either<Failure, T>> saveLocalAndSync<T>({
    required Future<void> Function() localSave,
    required Future<T> Function() remoteSave,
    required Future<void> Function(T remote) onSyncSuccess,
    required T localResult,
  }) async {
    try {
      await localSave();

      final connected = await isConnected;
      if (!connected) {
        return Right(localResult);
      }

      try {
        final remote = await remoteSave();
        await onSyncSuccess(remote);
        return Right(remote);
      } catch (e) {
        return Right(localResult);
      }
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    _debounceTimer?.cancel();
    super.onClose();
  }
}
