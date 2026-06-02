import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';

enum SyncState { idle, loading, success, error }

class SyncEngine {
  final SyncRepository repository;
  final NetworkService network;
  final SyncQueueRepository queueRepository;
  final String table;

  SyncEngine({
    required this.repository,
    required this.network,
    required this.queueRepository,
    required this.table,
  });

  bool _isSyncing = false;

  final Rx<SyncState> syncState = SyncState.idle.obs;

  /// 🔥 منع التكرار الحقيقي (localId + table)
  final Set<int> _processingIds = {};

  // ========================================================
  // FULL SYNC
  // ========================================================
  Future<void> sync() async {
    if (_isSyncing) return;

    final connected = await network.isConnected;
    if (!connected) return;

    final queue = await queueRepository.getQueue();

    final items = queue.where((e) => e.table == table).toList();

    if (items.isEmpty) return;

    _isSyncing = true;
    syncState.value = SyncState.loading;

    try {
      for (final item in items) {
        await _processSafely(item);
        await queueRepository.removeFromQueue(item.isarId);
      }

      syncState.value = SyncState.success;
    } catch (e) {
      syncState.value = SyncState.error;
      rethrow;
    } finally {
      _isSyncing = false;
      _resetStateToIdle();
    }
  }

  // ========================================================
  // SAFE PROCESSOR (ANTI DUPLICATION)
  // ========================================================
  Future<void> _processSafely(SyncQueueModel item) async {
    if (_processingIds.contains(item.isarId)) return;

    _processingIds.add(item.isarId);

    try {
      switch (item.action) {
        case SyncAction.create:
          await repository.createByLocalId(item.isarId);
          break;

        case SyncAction.update:
          await repository.updateByLocalId(item.isarId);
          break;

        case SyncAction.delete:
          await repository.deleteByLocalId(item.isarId);
          break;
      }
    } finally {
      _processingIds.remove(item.isarId);
    }
  }

  void _resetStateToIdle() {
    Future.delayed(const Duration(seconds: 2), () {
      syncState.value = SyncState.idle;
    });
  }
}
