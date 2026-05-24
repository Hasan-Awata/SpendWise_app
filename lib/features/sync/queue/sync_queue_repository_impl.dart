import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'sync_queue_model.dart';
import 'sync_queue_repository.dart';

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final Isar isar;

  // 🔥 بدل bool استخدم counter (الأهم)
  final RxInt queueVersion = 0.obs;

  SyncQueueRepositoryImpl(this.isar);

  // =========================
  // ADD TO QUEUE
  // =========================
  @override
  Future<void> addToQueue(SyncQueueModel item) async {
    print("\nadd to queue ==>> ${item.table}\n");

    await isar.writeTxn(() async {
      await isar.syncQueueModels.put(item);
    });

    // 🔥 trigger event
    queueVersion.value++;
  }

  // =========================
  // GET QUEUE
  // =========================
  @override
  Future<List<SyncQueueModel>> getQueue() async {
    return await isar.syncQueueModels.where().findAll();
  }

  // =========================
  // REMOVE ITEM
  // =========================
  @override
  Future<void> removeFromQueue(int isarId) async {
    await isar.writeTxn(() async {
      final item = await isar.syncQueueModels
          .filter()
          .isarIdEqualTo(isarId)
          .findFirst();

      if (item != null) {
        await isar.syncQueueModels.delete(item.idIsar);
      }
    });

    queueVersion.value++;
  }

  // =========================
  // CLEAR ALL
  // =========================
  @override
  Future<void> clearQueue() async {
    await isar.writeTxn(() async {
      await isar.syncQueueModels.clear();
    });

    queueVersion.value++;
  }
}
