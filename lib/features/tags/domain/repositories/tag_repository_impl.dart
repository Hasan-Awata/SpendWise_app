import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDatasource tagLocalDatasource;
  TagRepositoryImpl({required this.tagLocalDatasource});

  @override
  Future<void> addTag(TagModel? tag) async {
    await tagLocalDatasource.addTagLocally(tag);
  }

  @override
  Future<List<TagModel>> myTags() async {
    return await tagLocalDatasource.getMyTags();
  }
}
