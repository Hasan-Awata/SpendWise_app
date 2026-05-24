import 'package:flutter/foundation.dart';
import 'package:spendwise/features/sync/repository/sync_repository.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';

class TagSyncRepository implements SyncRepository<TagModel> {
  final TagLocalDatasource local;
  final TagRemoteDatasource remote;

  TagSyncRepository({required this.local, required this.remote});

  @override
  Future<void> createByLocalId(int localId) async {
    // جلب العنصر محلياً
    final tag = await local.getTagByIsarId(localId);
    if (tag == null) return;

    try {
      final remoteTag = await remote.addTag(tag);
      if (remoteTag != null) {
        tag.id = remoteTag.id;
        tag.isSynced = true;
        await local.updateTagLocally(tag);
      }
    } catch (e) {
      final errorString = e.toString();

      if (errorString.contains("409") || errorString.contains("Conflict")) {
        if (kDebugMode) {
          print(
            "⚠️ TagSyncRepository: Tag already exists on server (409). Resolving conflict locally...",
          );
        }

        tag.isSynced = true;
        await local.updateTagLocally(tag);
        return;
      }

      rethrow;
    }
  }

  @override
  Future<void> updateByLocalId(int localId) async {
    final tag = await local.getTagByIsarId(localId);
    if (tag == null) return;

    await remote.updateTag(tag);
    tag.isSynced = true;
    await local.updateTagLocally(tag);
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final tag = await local.getTagByIsarId(localId);

    if (tag == null) return;

    // =========================
    // إذا العنصر غير متزامن مع السيرفر
    // نحذفه محلياً مباشرة
    // =========================

    if (tag.id == null || tag.id == -1) {
      await local.deleteTagLocally(tag);
      return;
    }

    // =========================
    // حذف من السيرفر
    // =========================

    final isRemoved = await remote.deleteTag(tag.id!);

    if (!isRemoved) {
      throw Exception("فشل حذف التاج من السيرفر");
    }

    // =========================
    // حذف محلي بعد نجاح السيرفر
    // =========================

    await local.deleteTagLocally(tag);
  }
}
