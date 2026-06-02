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
    final tag = await local.getTagByIsarId(localId);
    if (tag == null) return;

    // 🔴 منع إعادة الإرسال إذا تم مزامنته مسبقاً
    if (tag.isSynced == true && tag.id != null) return;

    try {
      final remoteTag = await remote.addTag(tag);

      if (remoteTag != null) {
        tag
          ..id = remoteTag.id
          ..isSynced = true;

        await local.updateTagLocally(tag);
      }
    } catch (e) {
      final msg = e.toString();

      // 🟡 معالجة تكرار السيرفر (Conflict)
      if (msg.contains("409") || msg.contains("Conflict")) {
        if (kDebugMode) {
          print("⚠️ Tag already exists on server (409) -> mark synced");
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

    // 🔴 لا تحدث إذا غير مرتبط بالسيرفر
    if (tag.id == null) return;

    try {
      await remote.updateTag(tag);

      tag.isSynced = true;
      await local.updateTagLocally(tag);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteByLocalId(int localId) async {
    final tag = await local.getTagByIsarId(localId);
    if (tag == null) return;

    // 🔴 إذا لم يُرفع للسيرفر → حذف محلي فقط
    if (tag.id == null || tag.id == -1) {
      await local.deleteTagLocally(tag);
      return;
    }

    try {
      final isRemoved = await remote.deleteTag(tag.id!);

      if (!isRemoved) {
        throw Exception("Failed to delete tag from server");
      }

      await local.deleteTagLocally(tag);
    } catch (e) {
      rethrow;
    }
  }
}
