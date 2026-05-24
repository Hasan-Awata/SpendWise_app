import 'package:get/get.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository_impl.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkService(), permanent: true);
    Get.put<SyncQueueRepository>(
      SyncQueueRepositoryImpl(InitIsar.isar!),
      permanent: true,
    );
  }
}
