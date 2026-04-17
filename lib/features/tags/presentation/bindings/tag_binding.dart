import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource_impl.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/repositories/tag_repository_impl.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/delete_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/update_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/sync_pending_tags_usecase.dart';
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

// This binding class manages the immediate injection of tag-related dependencies using Get.put
class TagBinding implements Bindings {
  @override
  void dependencies() {
    // 1. DataSources
    // We use Get.put to initialize the data sources immediately in memory
    Get.put<TagRemoteDatasource>(
      TagRemoteDatasourceImpl(client: http.Client()),
    );

    Get.put<TagLocalDatasource>(TagLocalDatasourceImpl());

    // 2. Repository
    // Mapping the interface to the implementation for immediate availability
    Get.put<TagRepository>(
      TagRepositoryImpl(
        tagLocalDatasource: Get.find<TagLocalDatasource>(),
        tagRemoteDatasource: Get.find<TagRemoteDatasource>(),
      ),
    );

    // 3. UseCases
    Get.put(AddTagUsecase(Get.find<TagRepository>()));
    Get.put(GetMyTagsUsecase(Get.find<TagRepository>()));
    Get.put(DeleteTagUsecase(Get.find<TagRepository>()));
    Get.put(UpdateTagUsecase(Get.find<TagRepository>()));
    Get.put(SyncPendingTagsUsecase(Get.find<TagRepository>()));

    // 4. Controllers
    Get.put(
      TagActionController(
        updateTagUsecase: Get.find<UpdateTagUsecase>(),
        deleteTagUsecase: Get.find<DeleteTagUsecase>(),
        addTagUsecase: Get.find<AddTagUsecase>(),
      ),
    );

    Get.put(
      TagViewController(
        getMyTagsUsecase: Get.find<GetMyTagsUsecase>(),
        syncPendingTagsUsecase: Get.find<SyncPendingTagsUsecase>(),
      ),
    );
  }
}
