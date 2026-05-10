import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
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

// This binding class manages the immediate injection of tag-related dependencies using Get.put
class TagBinding implements Bindings {
  @override
  void dependencies() {
    // 1. DataSources
    // We use Get.put to initialize the data sources immediately in memory
    Get.put<TagRemoteDatasource>(
      TagRemoteDatasourceImpl(client: http.Client()),
    );

    Get.put<TagLocalDatasource>(TagLocalDatasourceImpl(Get.find<Isar>()));

    Get.lazyPut<NetworkService>(() => NetworkService(), fenix: true);

    Get.put<TagRepository>(
      TagRepositoryImpl(
        local: Get.find<TagLocalDatasource>(),
        remote: Get.find<TagRemoteDatasource>(),
        network: Get.find<NetworkService>(),
      ),
    );

    // 3. UseCases
    Get.put(AddTagUsecase(Get.find<TagRepository>()));
    Get.put(GetMyTagsUsecase(Get.find<TagRepository>()));
    Get.put(DeleteTagUsecase(Get.find<TagRepository>()));
    Get.put(UpdateTagUsecase(Get.find<TagRepository>()));

    Get.put(TagViewController(getMyTagsUsecase: Get.find<GetMyTagsUsecase>()));
    // 4. Controllers
    Get.put(
      TagActionController(
        updateTagUsecase: Get.find<UpdateTagUsecase>(),
        deleteTagUsecase: Get.find<DeleteTagUsecase>(),
        addTagUsecase: Get.find<AddTagUsecase>(),
        userIdUsecase: Get.find<GetUserIdUsecase>(),
        tagViewController: Get.find<TagViewController>(),
      ),
    );

    Get.put(TagViewController(getMyTagsUsecase: Get.find<GetMyTagsUsecase>()));
  }
}
