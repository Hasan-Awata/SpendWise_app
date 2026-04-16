// // تعليق: مصدر بيانات الأوسمة المحلي يعتمد الآن على مفتاح واحد لتخزين مصفوفة كاملة
import 'package:hive/hive.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagLocalDatasourceImpl implements TagLocalDatasource {
  static final TagLocalDatasourceImpl _instance =
      TagLocalDatasourceImpl._internal();
  factory TagLocalDatasourceImpl() => _instance;
  TagLocalDatasourceImpl._internal();

  static const String _boxName = "TAG_BOX";
  static const String _tagKey = "tag_list_key"; // المفتاح الوحيد للمصفوفة

  late Box _box;

  @override
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox(_boxName);
      } else {
        _box = Hive.box(_boxName);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> getMyTags() async {
    try {
      final data = _box.get(_tagKey);
      if (data == null) return [];
      // تحويل البيانات من النوع الديناميكي إلى قائمة موديلات
      return List<TagModel>.from(data);
    } catch (e) {
      return <TagModel>[];
    }
  }

  @override
  Future<TagModel?> addTagLocally(TagModel? tag) async {
    if (tag == null) return null;
    try {
      final tags = await getMyTags();
      // منع تكرار الوسم بنفس الاسم محلياً
      if (tags.any((t) => t.name.toLowerCase() == tag.name.toLowerCase())) {
        throw Exception("هذا الوسم موجود بالفعل");
      }
      final newTags = List<TagModel>.from(tags)..add(tag);
      await _box.put(_tagKey, newTags);
      return tag;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTagLocally(TagModel tag) async {
    try {
      List<TagModel> tags = await getMyTags();
      int index = tags.indexWhere((t) => t.localId == tag.localId);

      if (index != -1) {
        tags[index] = tag;
        await _box.put(_tagKey, tags);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTagLocally(TagModel tag) async {
    try {
      List<TagModel> tags = await getMyTags();
      // الحذف باستخدام localId لضمان الدقة قبل المزامنة
      tags.removeWhere((t) => t.localId == tag.localId);
      await _box.put(_tagKey, tags);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> getUnsyncedTags() async {
    final allTags = await getMyTags();
    return allTags.where((tag) => tag.isSynced == false).toList();
  }

  @override
  Future<void> clear() async {
    try {
      await _box.delete(
        _tagKey,
      ); // حذف المفتاح بالكامل أسرع من وضع مصفوفة فارغة
    } catch (e) {
      rethrow;
    }
  }
}
