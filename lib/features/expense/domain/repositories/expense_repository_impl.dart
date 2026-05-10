import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDatasource;
  final ExpenseLocalDataSource localDataSource;
  final NetworkService network;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
    required this.network,
  });

  // =========================
  // ADD
  // =========================
  @override
  Future<Either<Failure, String>> addExpense(ExpenseEntity expense) async {
    try {
      final exists = await localDataSource.checkIfExpenseExists(
        expense.localId,
      );
      if (exists) return Left(CacheFailure("Already exists"));

      final model = ExpenseModel.fromEntity(expense)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await localDataSource.addExpense(model);

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
  Future<Either<Failure, Unit>> updateExpense(ExpenseEntity entity) async {
    try {
      final local = localDataSource.getExpense(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..amount = entity.amount
        ..title = entity.title
        ..date = entity.date
        ..description = entity.description
        ..products = entity.products
        ..walletId = entity.walletId
        ..expenseTagId = entity.expenseTagId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateExpense(local);

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
  Future<Either<Failure, Unit>> deleteExpense(ExpenseEntity entity) async {
    try {
      final local = localDataSource.getExpense(entity.localId);
      if (local == null) return Left(CacheFailure("Not found"));

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateExpense(local);

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
  Future<Either<Failure, PagedResponse<ExpenseEntity>>> getExpenses(
    int? userId,
    PageRequest page,
  ) async {
    try {
      // 1. جلب البيانات المحلية فوراً (استجابة سريعة للواجهة)
      final localexpenses = await localDataSource.getExpenses();

      // 2. تشغيل المزامنة في الخلفية بدون انتظار (Background Sync)
      // هذا يمنع الدالة من الانتظار ويحل مشكلة الـ Loop
      if (await network.isConnected && userId != null) {
        _performBackgroundSync(userId, page, localexpenses);
      }

      // 3. معالجة البيانات المحلية الحالية للعرض (Filter & Sort)
      final filtered = localexpenses.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // 4. تطبيق الـ Pagination محلياً
      final start = (page.pageNumber - 1) * page.pageSize;
      final end = (start + page.pageSize).clamp(0, filtered.length);
      final slice = start >= filtered.length
          ? <ExpenseModel>[]
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
    List<ExpenseModel> localData,
  ) async {
    try {
      final remote = await remoteDatasource.getMyExpenses(userId, page);
      for (final item in remote.data) {
        final existing = localData.firstWhereOrNull(
          (e) => e.id != null && e.id == item.id,
        );

        if (existing != null) {
          item
            ..localId = existing.localId
            ..isarId = existing.isarId;
          await localDataSource.updateExpense(item..isSynced = true);
        } else {
          await localDataSource.addExpense(item..isSynced = true);
        }
      }
    } catch (e) {
      debugPrint("Background Sync Error: $e");
    }
  }
  // =========================
  // SAFE SYNC HELPERS (NO CRASH)
  // =========================

  void _trySyncCreate(ExpenseModel item) async {
    if (!await network.isConnected) return;

    try {
      final res = await remoteDatasource.addExpense(item);
      if (res != null) {
        item
          ..id = res.id
          ..isSynced = true;

        await localDataSource.updateExpense(item);
      }
    } catch (_) {
      item.isSynced = false;
      await localDataSource.updateExpense(item);
    }
  }

  void _trySyncUpdate(ExpenseModel item) async {
    if (!await network.isConnected) return;

    try {
      await remoteDatasource.updateExpense(item);
      item.isSynced = true;
      await localDataSource.updateExpense(item);
    } catch (_) {}
  }

  void _trySyncDelete(ExpenseModel item) async {
    if (!await network.isConnected) return;

    try {
      if (item.id != null) {
        await remoteDatasource.deleteExpense(item);
      }
      await localDataSource.deleteExpense(item);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpensesLocal() async {
    try {
      final data = await localDataSource.getExpenses();
      return Right(
        data.where((e) => !e.isDeleted).map((e) => e.toEntity()).toList(),
      );
    } catch (_) {
      return Left(CacheFailure("Local fetch failed"));
    }
  }
}
