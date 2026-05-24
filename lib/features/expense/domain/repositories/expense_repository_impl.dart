// =========================================================================
// تطبيق مستودع المصاريف المعدل ليعتمد بالكامل على طابور المزامنة الموحد
// =========================================================================

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
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:uuid/uuid.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final WalletLocalDatasource walletLocalDatasource;
  final CurrencyLocal currencyLocal;
  final SyncQueueRepository syncQueueRepository;
  final ExpenseRemoteDataSource remote;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.walletLocalDatasource,
    required this.currencyLocal,
    required this.syncQueueRepository,
    required this.remote,
  });

  // =====================================================
  // ADD EXPENSE (LOCAL ONLY + QUEUE)
  // =====================================================
  @override
  Future<Either<Failure, String>> addExpense(ExpenseEntity expense) async {
    try {
      final exists = await localDataSource.checkIfExpenseExists(
        expense.localId,
      );

      if (exists) {
        return Left(CacheFailure("Expense already exists"));
      }

      final model = ExpenseModel.fromEntity(expense)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // 1. حفظ في قاعدة البيانات المحلية فوراً لتحديث الشاشة للمستخدم
      await localDataSource.addExpense(model);

      // 2. إدراج العملية في طابور المزامنة
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: model.localId,
          action: SyncAction.create,
          table: "expense",
          createdAt: DateTime.now(),
          isarId: model.isarId,
        ),
      );

      return const Right("Saved locally and waiting for sync");
    } catch (e) {
      return Left(CacheFailure("Add expense locally failed: ${e.toString()}"));
    }
  }

  // =====================================================
  // UPDATE EXPENSE (LOCAL ONLY + QUEUE)
  // =====================================================
  @override
  Future<Either<Failure, Unit>> updateExpense(ExpenseEntity entity) async {
    try {
      final local = await localDataSource.getExpense(entity.localId);

      if (local == null) {
        return Left(CacheFailure("Expense not found for update"));
      }

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

      // 1. تحديث البيانات محلياً
      await localDataSource.updateExpense(local);

      // 2. تسجيل عملية التعديل في الطابور
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: local.localId,
          action: SyncAction.update,
          table: "expense",
          createdAt: DateTime.now(),
          isarId: local.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure("Update expense locally failed: ${e.toString()}"),
      );
    }
  }

  // =====================================================
  // DELETE EXPENSE (LOCAL ONLY + QUEUE)
  // =====================================================
  @override
  Future<Either<Failure, Unit>> deleteExpense(ExpenseEntity entity) async {
    try {
      final local = await localDataSource.getExpense(entity.localId);

      if (local == null) {
        return Left(CacheFailure("Expense not found for delete"));
      }

      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      // 1. وسم المصروف كمحذوف محلياً (Soft Delete) حتى يختفي من الواجهات فوراً
      await localDataSource.updateExpense(local);

      // 2. إضافة أمر الحذف إلى طابور المزامنة لمسحه من السيرفر لاحقاً
      await syncQueueRepository.addToQueue(
        SyncQueueModel(
          id: const Uuid().v4(),
          localId: local.localId,
          action: SyncAction.delete,
          table: "expense",
          createdAt: DateTime.now(),
          isarId: local.isarId,
        ),
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure("Delete expense locally failed: ${e.toString()}"),
      );
    }
  }

  // =====================================================
  // GET EXPENSES (OFFLINE-FIRST ONLY)
  // =====================================================
  @override
  Future<Either<Failure, PagedResponse<ExpenseEntity>>> getExpenses(
    int? userId,
    PageRequest page,
  ) async {
    try {
      final networkService = Get.find<NetworkService>();
      final isOnline = networkService.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getMyExpenses(userId!, page);

          if (remoteResponse != null) {
            await localDataSource.clear();

            for (var remoteExpense in remoteResponse.data) {
              remoteExpense.isSynced = true;
              remoteExpense.isDeleted = false;
              await localDataSource.addExpense(remoteExpense);
            }
          }
        } catch (remoteError) {
          if (kDebugMode) {
            print("⚠️ Failed to fetch expenses from remote: $remoteError");
          }
        }
      }

      final localExpenses = await localDataSource.getExpenses();

      final filtered = localExpenses.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final slice = _paginate(filtered, page);
      final entities = _mapToEntities(slice);

      return Right(
        PagedResponse(
          data: entities,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: (filtered.length / page.pageSize).ceil(),
        ),
      );
    } catch (e) {
      debugPrint("GetExpenses Error: $e");
      return Left(CacheFailure("Failed to fetch expenses: ${e.toString()}"));
    }
  }

  // =====================================================
  // HELPERS
  // =====================================================
  List<ExpenseModel> _paginate(List<ExpenseModel> list, PageRequest page) {
    final start = (page.pageNumber - 1) * page.pageSize;
    final end = (start + page.pageSize).clamp(0, list.length);

    return start >= list.length ? [] : list.sublist(start, end);
  }

  List<ExpenseEntity> _mapToEntities(List<ExpenseModel> slice) {
    return slice.map((model) {
      WalletEntity? wallet;

      if (model.walletLocalId != null) {
        final walletModel = walletLocalDatasource.getWallet(
          model.walletLocalId!,
        );

        if (walletModel != null) {
          walletModel.currency = currencyLocal.tryCurrencyById(
            walletModel.currencyId,
          );

          wallet = walletModel.toEntity();
        }
      }

      return model.toEntity(wallet: wallet);
    }).toList();
  }
}
