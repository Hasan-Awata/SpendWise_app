import 'package:get/get.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource_impl.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/repositories/tag_repository_impl.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/delete_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/update_tag_usecase.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

class TagBinding implements Bindings {
  @override
  void dependencies() {
    // =====================================================
    // 1. SERVICES & DATA SOURCES (الحقن المستقر والدائم)
    // =====================================================

    if (!Get.isRegistered<TagRemoteDatasource>()) {
      Get.put<TagRemoteDatasource>(
        TagRemoteDatasourceImpl(network: Get.find<NetworkService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<TagLocalDatasource>()) {
      Get.put<TagLocalDatasource>(
        TagLocalDatasourceImpl(InitIsar.isar!),
        permanent: true,
      );
    }

    // =====================================================
    // 2. REPOSITORY
    // =====================================================

    if (!Get.isRegistered<TagRepository>()) {
      Get.put<TagRepository>(
        TagRepositoryImpl(
          local: Get.find<TagLocalDatasource>(),
          syncQueueRepository: Get.find<SyncQueueRepository>(),
          remote: Get.find<TagRemoteDatasource>(),
        ),
        permanent: true,
      );
    }

    // =====================================================
    // 3. USE CASES
    // =====================================================

    if (!Get.isRegistered<AddTagUsecase>()) {
      Get.put(AddTagUsecase(Get.find<TagRepository>()), permanent: true);
    }
    if (!Get.isRegistered<GetMyTagsUsecase>()) {
      Get.put(GetMyTagsUsecase(Get.find<TagRepository>()), permanent: true);
    }
    if (!Get.isRegistered<DeleteTagUsecase>()) {
      Get.put(DeleteTagUsecase(Get.find<TagRepository>()), permanent: true);
    }
    if (!Get.isRegistered<UpdateTagUsecase>()) {
      Get.put(UpdateTagUsecase(Get.find<TagRepository>()), permanent: true);
    }

    // =====================================================
    // 4. CONTROLLERS (الاستدعاء الكسول الذكي وإعادة الإحياء التلقائي)
    // =====================================================

    // متحكم عرض وقراءة الأوسوم/التصنيفات
    Get.lazyPut<TagViewController>(
      () => TagViewController(getMyTagsUseCase: Get.find<GetMyTagsUsecase>()),
      fenix: true,
    );

    // متحكم العمليات (إضافة، تعديل، حذف)
    Get.lazyPut<TagActionController>(
      () => TagActionController(
        updateTagUsecase: Get.find<UpdateTagUsecase>(),
        deleteTagUsecase: Get.find<DeleteTagUsecase>(),
        addTagUsecase: Get.find<AddTagUsecase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        tagViewController: Get.find<TagViewController>(),
      ),
      fenix: true,
    );
  }
}
