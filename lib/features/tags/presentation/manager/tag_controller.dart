import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/domain/usecases/add_tag_usecase.dart';
import 'package:spendwise/features/tags/domain/usecases/get_my_tags_usecase.dart';

class TagController extends GetxController {
  final AddTagUsecase addTagUsecase;
  final GetMyTagsUsecase getMyTagsUsecase;
  TagController({required this.addTagUsecase, required this.getMyTagsUsecase});

  var tag = Rxn<TagModel>();
  var myTags = <TagModel>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTags();
  }

  Future<void> addtag() async {
    try {
      await addTagUsecase.call(tag.value);
      await loadTags();
    } on Exception catch (e) {
      HelperFunction.showSnackBar("Error", e.toString());
    }
  }

  Future<void> loadTags() async {
    try {
      isLoading.value = true;
      final tags = await getMyTagsUsecase.call();
      myTags.assignAll(tags);
    } on Exception catch (e) {
      HelperFunction.showSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
