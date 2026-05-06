import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

abstract class TagRemoteDatasource {
  Future<TagModel?> addTag(TagModel tag);

  Future<void> deleteTag(int id);

  Future<PagedResponse<TagModel>> getMyTags(PageRequest page);

  Future<TagModel?> updateTag(TagModel tag);
}
