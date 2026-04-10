import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagRepository {
  Future<List<TagModel>> myTags();
  Future<void> addTag(TagModel? tag);
}
