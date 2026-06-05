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
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/sync/queue/sync_queue_model.dart';
import 'package:spendwise/features/sync/queue/sync_queue_repository.dart';
import 'package:spendwise/features/wallet/data/repositories/wallet_repository.dart';
import 'package:uuid/uuid.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remote;
  final SyncQueueRepository syncQueueRepository;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remote,
    required this.syncQueueRepository,
  });

  // =========================
  // ADD
  // =========================

  @override
  Future<Either<Failure, String>> addExpense(ExpenseEntity expense) async {
    try {
      final walletRepo = Get.find<WalletRepository>();
      final balanceResult = await walletRepo.getWalletBalance(
        walletId: expense.walletId!,
      );

      // // التحقق من كفاية الرصيد
      // final isSufficient = balanceResult.fold(
      //   (l) => false,
      //   (total) => total >= expense.amount,
      // );
      // if (!isSufficient) {
      //   return Left(
      //     ServerFailure(
      //       'عذراً، الرصيد المتاح للعملة المختارة غير كافٍ لإتمام العملية.',
      //     ),
      //   );
      // }

      final network = Get.find<NetworkService>();

      final model = ExpenseModel.fromEntity(expense)
        ..isSynced = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // =========================
      // OFFLINE
      // =========================

      if (!network.isOnline.value) {
        await localDataSource.addExpense(model);
        await _addToQueue(model, SyncAction.create);
        return const Right('Expense saved offline');
      }

      // =========================
      // ONLINE
      // =========================

      final remoteExpense = await remote.addExpense(model);

      if (remoteExpense == null) {
        return Left(ServerFailure('Server returned null response'));
      }

      // =========================
      // BUDGET LIMIT
      // =========================

      if (remoteExpense.isOverLimit == true) {
        HelperFunction.showSnackBar(
          "تنبيه ميزانية",
          "لقد تجاوزت الميزانية المحددة للفئة في هذا المصروف",
          isError: true,
        );
      }

      // =========================
      // SAVE LOCAL AFTER SUCCESS
      // =========================

      model
        ..id = remoteExpense.id
        ..isSynced = true;

      await localDataSource.addExpense(model);

      return const Right('Expense saved');
    } catch (e) {
      return Left(ServerFailure('Add expense failed: $e'));
    }
  }

  // =========================
  // UPDATE
  // =========================

  @override
  Future<Either<Failure, Unit>> updateExpense(ExpenseEntity entity) async {
    try {
      final local = await localDataSource.getExpense(entity.localId);

      if (local == null) {
        return Left(CacheFailure('Expense not found'));
      }

      final walletRepo = Get.find<WalletRepository>();
      print("walllet is ----->${entity.walletId}");
      final balanceResult = await walletRepo.getWalletBalance(
        walletId: entity.walletId!,
      );

      final isSufficient = balanceResult.fold(
        (l) => false,
        (total) => total >= entity.amount,
      );
      if (!isSufficient) {
        return Left(
          CacheFailure('لا يمكن التحديث، الرصيد غير كافٍ لتغطية هذا المبلغ.'),
        );
      }

      local
        ..amount = entity.amount
        ..title = entity.title
        ..date = entity.date
        ..description = entity.description
        ..walletId = entity.walletId
        ..expenseTagId = entity.expenseTagId
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.updateExpense(local);

      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remote.updateExpense(local);
          local.isSynced = true;
          await localDataSource.updateExpense(local);
        } catch (_) {
          await _addToQueue(local, SyncAction.update);
        }
      } else {
        await _addToQueue(local, SyncAction.update);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Update expense failed: $e'));
    }
  }
  // =========================
  // DELETE
  // =========================

  @override
  Future<Either<Failure, Unit>> deleteExpense(ExpenseEntity entity) async {
    try {
      final local = await localDataSource.getExpense(entity.localId);

      if (local == null) {
        return Left(CacheFailure('Expense not found'));
      }

      // =========================
      // 1. تحديث رصيد المحفظة قبل الحذف
      // =========================
      final walletRepo = Get.find<WalletRepository>();
      await walletRepo.increaseBalance(
        walletId: local.walletId!,
        amountFromRegular: local.amount,
        amountFromSavings: 0.0,
      );

      // =========================
      // 2. تحديث حالة المصروف محلياً
      // =========================
      local
        ..isDeleted = true
        ..isSynced = false
        ..updatedAt = DateTime.now();

      await localDataSource.updateExpense(local);

      // =========================
      // 3. المزامنة مع السيرفر
      // =========================
      final network = Get.find<NetworkService>();

      if (network.isOnline.value) {
        try {
          await remote.deleteExpense(local);
          // في حال نجاح الحذف من السيرفر، نحذف السجل نهائياً من الـ Local
          await localDataSource.deleteExpense(local);
        } catch (_) {
          // في حال فشل السيرفر، نضيف العملية لطابور المزامنة
          await _addToQueue(local, SyncAction.delete);
        }
      } else {
        // إذا كان الجهاز غير متصل، نضيف العملية لطابور المزامنة
        await _addToQueue(local, SyncAction.delete);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Delete expense failed: $e'));
    }
  }
  // =========================
  // GET
  // =========================

  @override
  Future<Either<Failure, PagedResponse<ExpenseEntity>>> getExpenses(
    int? userId,
    PageRequest page,
  ) async {
    try {
      final network = Get.find<NetworkService>();
      final isOnline = network.isOnline.value;

      if (isOnline) {
        try {
          final remoteResponse = await remote.getMyExpenses(userId!, page);

          if (remoteResponse != null) {
            await localDataSource.clear();

            for (final expense in remoteResponse.data) {
              expense.isSynced = true;
              expense.isDeleted = false;
              await localDataSource.addExpense(expense);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Remote failed, fallback to local: $e");
          }
        }
      }

      final localData = await localDataSource.getExpenses();

      final filtered = localData.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final slice = _paginate(filtered, page);

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
      return Left(CacheFailure("Error loading ExgetExpenses: $e"));
    }
  }

  // =========================
  // QUEUE
  // =========================

  Future<void> _addToQueue(ExpenseModel model, SyncAction action) async {
    await syncQueueRepository.addToQueue(
      SyncQueueModel(
        id: const Uuid().v4(),
        localId: model.localId,
        isarId: model.isarId,
        table: 'expense',
        action: action,
        createdAt: DateTime.now(),
      ),
    );
  }

  // =========================
  // PAGINATION
  // =========================

  List<ExpenseModel> _paginate(List<ExpenseModel> list, PageRequest page) {
    final start = (page.pageNumber - 1) * page.pageSize;

    if (start >= list.length) {
      return [];
    }

    final end = (start + page.pageSize) > list.length
        ? list.length
        : start + page.pageSize;

    return list.sublist(start, end);
  }
}
