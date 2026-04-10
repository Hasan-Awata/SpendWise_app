import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagLocalDatasource {
  Future<void> init();
  Future<List<TagModel>> getMyTags();
  Future<void> addTagLocally(TagModel? tag);
}
