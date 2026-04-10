import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class AddTagUsecase {
  final TagRepository tagRepository;
  AddTagUsecase(this.tagRepository);

  Future<void> call(TagModel? tag) async {
    await tagRepository.addTag(tag);
  }
}
