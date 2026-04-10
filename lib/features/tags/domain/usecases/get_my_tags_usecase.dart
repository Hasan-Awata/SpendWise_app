import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class GetMyTagsUsecase {
  final TagRepository tagRepository;
  GetMyTagsUsecase(this.tagRepository);

  Future<List<TagModel>> call() async {
    return await tagRepository.myTags();
  }
}
