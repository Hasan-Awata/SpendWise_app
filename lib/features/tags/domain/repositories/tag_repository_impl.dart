import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/data/repositories/tag_repository.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';

// tag_repository_impl.dart

class TagRepositoryImpl implements TagRepository {
  final TagLocalDatasource local;
  final TagRemoteDatasource remote;
  final NetworkService network;

  TagRepositoryImpl({
    required this.local,
    required this.remote,
    required this.network,
  });

  // =========================
  // ADD
  // =========================
  @override
  Future<Either<Failure, String>> addTag(TagEntity tag) async {
    try {
      final model = TagModel.fromEntity(tag)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await local.addTagLocally(model);

      // مزامنة فورية (ننتظرها لضمان تحديث الـ UI بشكل صحيح)
      if (await network.isConnected) {
        await _syncItemSafe(model);
      }

      return const Right("تم الحفظ محلياً");
    } catch (e) {
      return Left(CacheFailure("فشل إضافة الوسم"));
    }
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<Either<Failure, Unit>> updateTag(TagEntity tag) async {
    try {
      final localTag = await local.getTag(tag.localId);
      if (localTag == null) return Left(CacheFailure("الوسم غير موجود"));

      localTag
        ..name = tag.name
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await local.updateTagLocally(localTag);

      if (await network.isConnected) {
        await _syncItemSafe(localTag);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث"));
    }
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<Either<Failure, String>> deleteTag(TagEntity tag) async {
    try {
      final localTag = await local.getTag(tag.localId);
      if (localTag == null) return Left(CacheFailure("الوسم غير موجود"));

      localTag
        ..isDeleted = true
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await local.updateTagLocally(localTag);

      if (await network.isConnected) {
        await _syncItemSafe(localTag);
      }

      return const Right("تم الحذف محلياً");
    } catch (e) {
      return Left(CacheFailure("فشل الحذف"));
    }
  }

  // =========================
  // GET (FETCH + BACKGROUND SYNC)
  // =========================
  @override
  Future<Either<Failure, PagedResponse<TagEntity>>> getMyTags(
    PageRequest page,
  ) async {
    try {
      // 1. جلب البيانات المحلية فوراً
      final localData = await local.getMyTags();

      // 2. المزامنة في الخلفية (بدون await) للعناصر غير المتزامنة
      if (await network.isConnected) {
        _performBackgroundSync(localData);
      }

      // 3. معالجة البيانات للعرض
      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

      // 4. Pagination
      final start = (page.pageNumber - 1) * page.pageSize;
      final end = (start + page.pageSize).clamp(0, filtered.length);
      final slice = start >= filtered.length
          ? <TagModel>[]
          : filtered.sublist(start, end);

      return Right(
        PagedResponse(
          data: slice.map((e) => e.toEntity()).toList(),
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: (filtered.length / page.pageSize).ceil(),
        ),
      );
    } catch (e) {
      return Left(CacheFailure("فشل جلب البيانات"));
    }
  }

  // =========================
  // CORE SYNC LOGIC
  // =========================

  void _performBackgroundSync(List<TagModel> items) {
    for (final item in items) {
      if (!item.isSynced) {
        _syncItemSafe(item).catchError((e) => debugPrint("Sync Error: $e"));
      }
    }
  }

  Future<void> _syncItemSafe(TagModel item) async {
    try {
      // حالة الحذف
      if (item.isDeleted) {
        if (item.id != null) {
          await remote.deleteTag(item.id!);
        }
        await local.deleteTagLocally(item);
        return;
      }

      // حالة الإضافة (إذا لم يكن هناك ID من السيرفر)
      if (item.id == null || item.id == -1) {
        final res = await remote.addTag(item);
        if (res != null) {
          item.id = res.id;
        }
      }
      // حالة التحديث
      else {
        await remote.updateTag(item);
      }

      // تحديث الحالة لمتزامن
      item
        ..isSynced = true
        ..syncAttempts = 0;

      await local.updateTagLocally(item);
    } catch (e) {
      item.syncAttempts += 1;
      // التوقف عن المحاولة بعد 5 مرات (تعتبر متزامنة وهمياً لمنع الـ Loop)
      if (item.syncAttempts > 5) {
        item.isSynced = true;
      }
      await local.updateTagLocally(item);
    }
  }
}
