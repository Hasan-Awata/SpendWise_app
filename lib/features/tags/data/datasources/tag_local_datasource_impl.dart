import 'package:hive/hive.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagLocalDatasourceImpl implements TagLocalDatasource {
  static final TagLocalDatasourceImpl _instance =
      TagLocalDatasourceImpl._internal();
  factory TagLocalDatasourceImpl() => _instance;
  TagLocalDatasourceImpl._internal();

  final String _boxName = "TAG";
  final String _tagKey = "tag_key";

  late Box _box;

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> addTagLocally(TagModel? tag) async {
    try {
      final tags = await getMyTags();
      tags.add(tag!);
      await _box.put(_tagKey, tags);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<TagModel>> getMyTags() async {
    return await _box.get(_tagKey) ?? <TagModel>[];
  }
}
