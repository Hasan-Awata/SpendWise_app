import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';

abstract class SyncQueueRepository {
  RxInt get queueVersion;
  Future<void> addToQueue(SyncQueueModel item);
  Future<List<SyncQueueModel>> getQueue();
  Future<void> removeFromQueue(int isarId);
  Future<void> clearQueue();
}
