import 'package:isar/isar.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagLocalDatasourceImpl implements TagLocalDatasource {
  final Isar isar;

  TagLocalDatasourceImpl(this.isar);

  @override
  Future<List<TagModel>> getMyTags() async {
    try {
      // جلب كافة الأوسمة من جدول TagModel
      return await isar.tagModels.where().findAll();
    } catch (e) {
      return <TagModel>[];
    }
  }

  @override
  Future<TagModel?> getTag(String localId) async {
    return await isar.tagModels.filter().localIdEqualTo(localId).findFirst();
  }

  @override
  Future<TagModel?> addTagLocally(TagModel? tag) async {
    if (tag == null) return null;
    try {
      // التحقق من تكرار الاسم باستخدام استعلام Isar (أسرع من الفلترة اليدوية)
      final existingTag = await isar.tagModels
          .filter()
          .nameEqualTo(tag.name, caseSensitive: false)
          .findFirst();

      if (existingTag != null) {
        throw Exception("هذا الوسم موجود بالفعل");
      }

      // حفظ الوسم في قاعدة البيانات
      await isar.writeTxn(() async {
        await isar.tagModels.put(tag);
      });

      return tag;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTagLocally(TagModel tag) async {
    try {
      await isar.writeTxn(() async {
        // Isar سيقوم بالتحديث تلقائياً لأن isarId (المشتق من localId) سيكون متطابقاً
        await isar.tagModels.put(tag);
      });
    } catch (e) {
      HelperFunction.showSnackBar("error", e.toString(), isError: true);
    }
  }

  @override
  Future<void> deleteTagLocally(TagModel tag) async {
    try {
      await isar.writeTxn(() async {
        // الحذف باستخدام الـ isarId الفريد
        await isar.tagModels.delete(tag.isarId);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> getUnsyncedTags() async {
    // استعلام مباشر لجلب الأوسمة غير المتزامنة
    return await isar.tagModels.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<bool> checkIftagExists(String localId) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.tagModels.filter().localIdEqualTo(localId).count();

    return count > 0;
  }

  @override
  Future<bool> checkIfTagExistsBytagId(int? id) async {
    // استخدام query مباشر للبحث عن الـ localId فقط دون جلب كافة البيانات للذاكرة
    final count = await isar.tagModels.filter().idEqualTo(id).count();

    return count > 0;
  }

  @override
  TagModel? getTagByServerId(int? tagId) {
    if (tagId == null) return null;

    return isar.tagModels.filter().idEqualTo(tagId).findFirstSync();
  }

  @override
  Future<void> saveOrUpdateRemotetag(TagModel remotetag) async {
    await isar.writeTxn(() async {
      final existing = await isar.tagModels
          .filter()
          .idEqualTo(remotetag.id)
          .findFirst();
      if (existing != null) {
        existing
          ..isSynced = true
          ..updatedAt = remotetag.updatedAt;
        await isar.tagModels.put(existing);
      } else {
        remotetag
          ..isSynced = true
          ..isDeleted = false;
        await isar.tagModels.put(remotetag);
      }
    });
  }

  @override
  Future<void> clear() async {
    try {
      await isar.writeTxn(() async {
        await isar.tagModels.clear();
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TagModel?> getTagByIsarId(int? localId) async {
    if (localId == null) return null;

    return isar.tagModels.filter().isarIdEqualTo(localId).findFirstSync();
  }
}
