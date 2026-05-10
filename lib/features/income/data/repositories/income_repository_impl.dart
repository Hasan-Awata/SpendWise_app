import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDatasource remoteDatasource;
  final IncomeLocalDataSource localDataSource;
  final NetworkService network;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.network,
  });

  // =========================
  // ADD
  // =========================
  @override
  Future<Either<Failure, String>> addIncome(IncomeEntity income) async {
    try {
      final exists = await localDataSource.checkIfIncomeExists(income.localId);
      if (exists) return Left(CacheFailure("Already exists"));

      final model = IncomeModel.fromEntity(income)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await localDataSource.addIncome(model);

      // sync best effort
      _trySyncCreate(model);

      return const Right("Saved locally");
    } catch (e) {
      return Left(CacheFailure("Add failed"));
    }
  }

  // =========================
  // UPDATE
  // =========================
  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeEntity entity) async {
    try {
      final local = localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..amount = entity.amount
        ..title = entity.title
        ..date = entity.date
        ..description = entity.description
        ..walletId = entity.walletId
        ..incomeTagId = entity.incomeTagId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateIncome(local);

      _trySyncUpdate(local);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Update failed"));
    }
  }

  // =========================
  // DELETE
  // =========================
  @override
  Future<Either<Failure, Unit>> deleteIncome(IncomeEntity entity) async {
    try {
      final local = localDataSource.getIncome(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateIncome(local);

      _trySyncDelete(local);

      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure("Delete failed"));
    }
  }

  // =====================================================
  // 🔥 أهم جزء: FETCH + SYNC داخل نفس الدالة
  // =====================================================
  @override
  Future<Either<Failure, PagedResponse<IncomeEntity>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    try {
      // 1. جلب البيانات المحلية فوراً (استجابة سريعة للواجهة)
      final localIncomes = await localDataSource.getIncomes();

      // 2. تشغيل المزامنة في الخلفية بدون انتظار (Background Sync)
      // هذا يمنع الدالة من الانتظار ويحل مشكلة الـ Loop
      if (await network.isConnected && userId != null) {
        _performBackgroundSync(userId, page, localIncomes);
      }

      // 3. معالجة البيانات المحلية الحالية للعرض (Filter & Sort)
      final filtered = localIncomes.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 4. تطبيق الـ Pagination محلياً
      final start = (page.pageNumber - 1) * page.pageSize;
      final end = (start + page.pageSize).clamp(0, filtered.length);
      final slice = start >= filtered.length
          ? <IncomeModel>[]
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
      return Left(CacheFailure("Fetch failed"));
    }
  }

  // دالة المزامنة المنفصلة
  void _performBackgroundSync(
    int userId,
    PageRequest page,
    List<IncomeModel> localData,
  ) async {
    try {
      final remote = await remoteDatasource.getMyIncomes(userId, page);
      for (final item in remote.data) {
        final existing = localData.firstWhereOrNull(
          (e) => e.id != null && e.id == item.id,
        );

        if (existing != null) {
          item
            ..localId = existing.localId
            ..isarId = existing.isarId;
          await localDataSource.updateIncome(item..isSynced = true);
        } else {
          await localDataSource.addIncome(item..isSynced = true);
        }
      }
    } catch (e) {
      debugPrint("Background Sync Error: $e");
    }
  }
  // =========================
  // SAFE SYNC HELPERS (NO CRASH)
  // =========================

  void _trySyncCreate(IncomeModel item) async {
    if (!await network.isConnected) return;

    try {
      final res = await remoteDatasource.addIncome(item);
      if (res != null) {
        item
          ..id = res.id
          ..isSynced = true;

        await localDataSource.updateIncome(item);
      }
    } catch (_) {
      item.isSynced = false;
      await localDataSource.updateIncome(item);
    }
  }

  void _trySyncUpdate(IncomeModel item) async {
    if (!await network.isConnected) return;

    try {
      await remoteDatasource.updateIncome(item);
      item.isSynced = true;
      await localDataSource.updateIncome(item);
    } catch (_) {}
  }

  void _trySyncDelete(IncomeModel item) async {
    if (!await network.isConnected) return;

    try {
      if (item.id != null) {
        await remoteDatasource.deleteIncome(item);
      }
      await localDataSource.deleteIncome(item);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<IncomeEntity>>> getAllIncomesLocal() async {
    try {
      final data = await localDataSource.getIncomes();
      return Right(
        data.where((e) => !e.isDeleted).map((e) => e.toEntity()).toList(),
      );
    } catch (_) {
      return Left(CacheFailure("Local fetch failed"));
    }
  }
}
