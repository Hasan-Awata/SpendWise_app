import 'package:dartz/dartz.dart';
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
      print("🚀 Starting addExpense: ${expense.localId}");
      expense.isSynced = false;
      await localDataSource.addExpense(expense);

      _safeRemoteCall(() async {
        final syncedModel = await remoteDatasource.addExpense(expense);
        if (syncedModel != null) {
          print("✅ Server Add Success: ${syncedModel.id}");
          syncedModel.isSynced = true;
          // الحفاظ على الـ localId لربط البيانات
          syncedModel.localId = expense.localId;
          await localDataSource.updateExpense(syncedModel);
        }
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Add Error: $e");
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<ExpenseModel>>> getExpenses(
    int? userId,
    PageRequest page,
  ) async {
    try {
      print("📡 Fetching Expenses from Server - Page: ${page.pageNumber}");
      final remoteResponse = await remoteDatasource.getMyExpenses(
        userId ?? 0,
        page,
      );

      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await localDataSource.addExpense(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      print("🌐 Connection Issue: Switching to Local Storage. Error: $e");
      _safeRemoteCall(() => syncPendingExpenses());
      return await _getLocalPagedExpenses(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateExpense(ExpenseModel expense) async {
    try {
      print("🔄 Updating Expense Locally: ${expense.id}");
      expense.isSynced = false;
      await localDataSource.updateExpense(expense);

      _safeRemoteCall(() async {
        if (expense.id != null) {
          final updatedRemote = await remoteDatasource.updateExpense(expense);
          if (updatedRemote != null) {
            print("✅ Server Update Sync Done");
            updatedRemote.isSynced = true;
            await localDataSource.updateExpense(updatedRemote);
          }
        }
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Update Error: $e");
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(ExpenseModel expense) async {
    try {
      print("🗑️ Marking Expense for Removal: ${expense.id}");
      expense.localId = "REMOVE";
      expense.isSynced = false;
      await localDataSource.updateExpense(expense);

      _safeRemoteCall(() async {
        if (expense.id != null && expense.id != -1) {
          await remoteDatasource.deleteExpense(expense);
          print("✅ Server Delete Done");
        }
        await localDataSource.deleteExpense(expense);
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Delete Error: $e");
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingExpenses() async {
    try {
      final allLocal = await localDataSource.getExpenses();
      final pending = allLocal
          .where((e) => !e.isSynced || e.localId == "REMOVE")
          .toList();

      print("🔄 Sync Engine (Expense): Found ${pending.length} pending items");

      for (var expense in pending) {
        try {
          if (expense.localId == "REMOVE") {
            if (expense.id != null) {
              await remoteDatasource.deleteExpense(expense);
            }
            await localDataSource.deleteExpense(expense);
            print("📤 Synced: DELETED Expense ${expense.id}");
            continue;
          }

          if (expense.id != null) {
            final updated = await remoteDatasource.updateExpense(expense);
            if (updated != null) {
              updated.isSynced = true;
              await localDataSource.updateExpense(updated);
              print("📤 Synced: UPDATED Expense ${expense.id}");
            }
          } else {
            final created = await remoteDatasource.addExpense(expense);
            if (created != null) {
              created.isSynced = true;
              created.localId = expense.localId;
              await localDataSource.updateExpense(created);
              print("📤 Synced: CREATED Expense ${created.id}");
            }
          }
        } catch (e) {
          print("⚠️ Sync Error for Expense item: $e");
          continue;
        }
      }

      return const Right(unit);
    } catch (e) {
      print("❌ Global Expense Sync Failure: $e");
      return Left(CacheFailure("فشل محرك المزامنة"));
    }
  }

  Future<Either<Failure, PagedResponse<ExpenseModel>>> _getLocalPagedExpenses(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getExpenses();
      // تصفية المحذوفات وترتيب الأحدث أولاً
      final filtered = all
          .where((e) => e.localId != "REMOVE")
          .toList()
          .reversed
          .toList();

      final start = (page.pageNumber - 1) * page.pageSize;
      final totalPages = (filtered.length / page.pageSize).ceil();

      if (start >= filtered.length) {
        return Right(
          PagedResponse(
            data: [],
            totalRecords: filtered.length,
            pageNumber: page.pageNumber,
            pageSize: page.pageSize,
            totalPages: totalPages,
          ),
        );
      }

      final end = start + page.pageSize;
      final sliced = filtered.sublist(
        start,
        end > filtered.length ? filtered.length : end,
      );

      print("📦 Local Expenses Loaded: ${sliced.length} items");
      return Right(
        PagedResponse(
          data: sliced,
          totalRecords: filtered.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      return Left(CacheFailure("قاعدة البيانات المحلية غير متاحة"));
    }
  }

  Future<void> _safeRemoteCall(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("📢 Expense Background Sync Silent Info: $e");
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getAllExpensesLocal() async {
    try {
      final expenses = await localDataSource.getExpenses();
      // إرجاع المصروفات غير المحذوفة فقط
      return Right(expenses.where((e) => e.localId != "REMOVE").toList());
    } catch (e) {
      return Left(CacheFailure("خطأ في القراءة المحلية"));
    }
  }
}
