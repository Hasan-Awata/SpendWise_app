import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagLocalDatasource {
  Future<void> init();

  Future<List<TagModel>> getMyTags();

  Future<TagModel?> addTagLocally(TagModel? tag);

  Future<void> updateTagLocally(TagModel tag);

  Future<void> deleteTagLocally(TagModel tag);

  Future<List<TagModel>> getUnsyncedTags();

  Future<void> clear();
}
