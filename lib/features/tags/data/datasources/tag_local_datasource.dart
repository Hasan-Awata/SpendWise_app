import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagLocalDatasource {
  Future<List<TagModel>> getMyTags();

  Future<TagModel?> addTagLocally(TagModel? tag);

  Future<void> updateTagLocally(TagModel tag);

  Future<void> deleteTagLocally(TagModel tag);

  Future<List<TagModel>> getUnsyncedTags();

  Future<TagModel?> getTag(String localId);
  Future<TagModel?> getTagByIsarId(int localId);
  Future<bool> checkIftagExists(String localId);

  Future<bool> checkIfTagExistsBytagId(int? id);

  TagModel? getTagByServerId(int? tagId);

  Future<void> saveOrUpdateRemotetag(TagModel remotetag);
  Future<void> clear();
}
