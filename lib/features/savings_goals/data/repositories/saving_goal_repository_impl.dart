// // تعليق: تنفيذ المستودع مع تطبيق استراتيجية المزامنة في الخلفية والتعامل مع الأخطاء المحلية والشبكية
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

import '../datasources/saving_goal_remote_datasource.dart';
import '../models/saving_goal_model.dart';
import '../repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalRemoteDatasource remoteDatasource;
  final SavingGoalLocalDatasource localDatasource;
  final NetworkService network;

  SavingGoalRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.network,
  });

  // =====================================================
  // ADD
  // =====================================================
  @override
  Future<Either<Failure, String>> addSavingGoal(SavingGoalEntity entity) async {
    try {
      final model = SavingGoalModel.fromEntity(entity)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await localDatasource.updateGoalLocal(model);

      _trySyncCreate(model);

      return const Right("Saved locally");
    } catch (_) {
      return Left(CacheFailure("Add failed"));
    }
  }

  // =====================================================
  // UPDATE
  // =====================================================
  @override
  Future<Either<Failure, Unit>> updateSavingGoal(
    SavingGoalEntity entity,
  ) async {
    try {
      final local = localDatasource.getSavingGoal(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..title = entity.title
        ..targetAmount = entity.targetAmount
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDatasource.updateGoalLocal(local);

      _trySyncUpdate(local);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Update failed"));
    }
  }

  // =====================================================
  // DELETE
  // =====================================================
  @override
  Future<Either<Failure, Unit>> deleteSavingGoal(
    SavingGoalEntity entity,
  ) async {
    try {
      final local = localDatasource.getSavingGoal(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDatasource.updateGoalLocal(local);

      _trySyncDelete(local);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Delete failed"));
    }
  }

  // =====================================================
  // 🔥 FETCH + SYNC (مكان واحد فقط للمزامنة)
  // =====================================================
  // saving_goal_repository_impl.dart

  @override
  Future<Either<Failure, PagedResponse<SavingGoalEntity>>> getMySavingGoals(
    int userId,
    PageRequest page,
  ) async {
    try {
      // 1. جلب البيانات المحلية فوراً لضمان سرعة الاستجابة
      final localData = await localDatasource.getAllGoalsLocal();

      // 2. تشغيل المزامنة في الخلفية (Background Sync) بدون await
      // هذا يمنع الـ Infinite Loop ويجعل التطبيق سلساً جداً
      if (await network.isConnected) {
        _performBackgroundSync(userId, page, localData);
      }

      // 3. فلترة البيانات المحلية (استبعاد المحذوف) وترتيبها
      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

      // 4. منطق تقسيم الصفحات (Pagination) محلياً
      final start = (page.pageNumber - 1) * page.pageSize;
      final end = (start + page.pageSize).clamp(0, filtered.length);
      final slice = start >= filtered.length
          ? <SavingGoalModel>[]
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
      return Left(CacheFailure("فشل جلب أهداف التوفير"));
    }
  }

  // دالة المزامنة الخلفية الصامتة
  void _performBackgroundSync(
    int userId,
    PageRequest page,
    List<SavingGoalModel> localData,
  ) async {
    try {
      // جلب البيانات من السيرفر
      final remote = await remoteDatasource.getAllUserGoals(userId, page);

      for (final remoteItem in remote.data) {
        // البحث عن الهدف في البيانات المحلية باستخدام goalId القادم من السيرفر
        final existing = localData.firstWhereOrNull(
          (e) => e.goalId != null && e.goalId == remoteItem.goalId,
        );

        if (existing != null) {
          // تحديث البيانات المحلية الموجودة مع الحفاظ على الـ IDs المحلية (Isar)
          remoteItem
            ..localId = existing.localId
            ..isarId = existing.isarId
            ..isSynced = true;
          await localDatasource.updateGoalLocal(remoteItem);
        } else {
          // إضافة هدف جديد إذا لم يكن موجوداً
          remoteItem.isSynced = true;
          await localDatasource.updateGoalLocal(remoteItem);
        }
      }
      // ملاحظة: لا حاجة لعمل refresh هنا، الـ Controller سيقوم بجلب البيانات في الطلب القادم
      // أو يمكن استخدام Stream إذا كنت تعتمد على المراقبة اللحظية.
    } catch (e) {
      debugPrint("Saving Goals Sync Error: $e");
    }
  }
  // =====================================================
  // SYNC HELPERS (SAFE - NO CRASH)
  // =====================================================

  void _trySyncCreate(SavingGoalModel item) async {
    if (!await network.isConnected) return;

    try {
      final res = await remoteDatasource.addGoal(item);

      item
        ..goalId = res.goalId
        ..isSynced = true;

      await localDatasource.updateGoalLocal(item);
    } catch (_) {
      item.isSynced = false;
      await localDatasource.updateGoalLocal(item);
    }
  }

  void _trySyncUpdate(SavingGoalModel item) async {
    if (!await network.isConnected) return;

    try {
      await remoteDatasource.updateGoal(item);

      item.isSynced = true;
      await localDatasource.updateGoalLocal(item);
    } catch (_) {}
  }

  void _trySyncDelete(SavingGoalModel item) async {
    if (!await network.isConnected) return;

    try {
      if (item.goalId != null) {
        await remoteDatasource.deleteGoal(item.goalId!);
      }
      await localDatasource.deleteGoalLocal(item.isarId);
    } catch (_) {}
  }

  // =====================================================
  // LOCAL ONLY
  // =====================================================
  @override
  Future<Either<Failure, List<SavingGoalEntity>>>
  getAllSavingGoalLocal() async {
    try {
      final goals = await localDatasource.getAllGoalsLocal();

      return Right(
        goals.where((g) => !g.isDeleted).map((e) => e.toEntity()).toList(),
      );
    } catch (_) {
      return Left(CacheFailure("Local fetch failed"));
    }
  }

  @override
  Future<Either<Failure, List<SavingGoalEntity>>> getAchievedGoals(
    int userId,
  ) async {
    try {
      final goals = await remoteDatasource.getAchievedGoals(userId);
      return Right(goals.map((e) => e.toEntity()).toList());
    } catch (_) {
      return Left(ServerFailure("Failed"));
    }
  }

  // required but not used
  @override
  Future<Either<Failure, Unit>> syncPendingGoals() async {
    return const Right(unit);
  }
}
