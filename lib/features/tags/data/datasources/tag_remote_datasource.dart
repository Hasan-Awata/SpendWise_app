import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagRemoteDatasource {
  Future<TagModel?> addTag(TagModel tag);

  Future<bool> deleteTag(int id);

  Future<List<TagModel>?> getMyTags();

  Future<TagModel?> updateTag(TagModel tag);
}
