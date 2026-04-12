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
      rethrow;
    }
  }

  @override
  Future<void> addTagLocally(TagModel? tag) async {
    try {
      final List<TagModel> tags = await getMyTags();
      tags.add(tag!);
      await _box.put(_tagKey, tags);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> getMyTags() async {
    final List? data = _box.get(_tagKey);
    if (data != null) {
      return List<TagModel>.from(data);
    }
    return <TagModel>[];
  }
}
