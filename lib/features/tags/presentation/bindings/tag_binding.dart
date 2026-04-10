import 'package:get/get.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/repositories/tag_repository_impl.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';

class TagBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TagLocalDatasource>(() => TagLocalDatasourceImpl());
    Get.lazyPut<TagRepository>(
      () => TagRepositoryImpl(tagLocalDatasource: Get.find()),
    );
    Get.lazyPut(() => AddTagUsecase(Get.find()));
    Get.lazyPut(() => GetMyTagsUsecase(Get.find()));

    Get.lazyPut(
      () => TagController(
        addTagUsecase: Get.find<AddTagUsecase>(),
        getMyTagsUsecase: Get.find<GetMyTagsUsecase>(),
      ),
    );
  }
}
