import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:spendwise/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/data/repositories/expense_repository.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDatasource;
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, Unit>> addExpense(ExpenseModel expense) async {
    try {
      await localDataSource.addExpense(expense);

      _safeRemoteCall(() async {
        final syncedModel = await remoteDatasource.addExpense(expense);
        syncedModel.isSynced = true;
        await localDataSource.updateExpense(syncedModel);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<ExpenseModel>>> getExpenses(
    int? userId,
    PageRequest page,
  ) async {
    if (userId == null) return _getLocalPagedExpenses(page);

    try {
      final remoteResponse = await remoteDatasource.getMyExpenses(userId, page);

      for (var expense in remoteResponse.data) {
        expense.isSynced = true;
        await localDataSource.addExpense(expense);
      }

      return Right(remoteResponse);
    } catch (e) {
      return await _getLocalPagedExpenses(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateExpense(ExpenseModel expense) async {
    try {
      expense.isSynced = false;
      await localDataSource.updateExpense(expense);

      _safeRemoteCall(() async {
        if (expense.id != null) {
          await remoteDatasource.updateExpense(expense);
          expense.isSynced = true;
          await localDataSource.updateExpense(expense);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(ExpenseModel expense) async {
    try {
      _safeRemoteCall(() async {
        if (expense.id != null) await remoteDatasource.deleteExpense(expense);
      });

      await localDataSource.deleteExpense(expense);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingExpenses() async {
    try {
      final allLocal = await localDataSource.getExpenses();
      final pending = allLocal
          .where((e) => e.isSynced != true || e.localId == "REMOVE")
          .toList();

      for (var expense in pending) {
        try {
          if (expense.localId == "REMOVE") {
            if (expense.id != null)
              await remoteDatasource.deleteExpense(expense);
            await localDataSource.deleteExpense(expense);
          } else {
            final remoteModel = await remoteDatasource.addExpense(expense);
            remoteModel.isSynced = true;
            await localDataSource.updateExpense(remoteModel);
          }
        } catch (_) {
          continue;
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل محرك المزامنة"));
    }
  }

  Future<void> _safeRemoteCall(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("Silent Sync Error: $e");
    }
  }

  Future<Either<Failure, PagedResponse<ExpenseModel>>> _getLocalPagedExpenses(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getExpenses();
      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (all.length / page.pageSize).ceil();

      if (start >= all.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: all.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = all.sublist(start, end > all.length ? all.length : end);

      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: all.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("قاعدة البيانات المحلية غير متاحة"));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getAllExpensesLocal() async {
    try {
      final expenses = await localDataSource.getExpenses();
      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure("خطأ في القراءة المحلية"));
    }
  }
}
