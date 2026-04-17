import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDatasource remoteDatasource;
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
  });

  // ================================
  // ✅ ADD INCOME (OFFLINE-FIRST)
  // ================================
  @override
  Future<Either<Failure, IncomeModel>> addIncome(IncomeModel income) async {
    try {
      // حفظ محلي أولاً
      income.isSynced = false;
      await localDataSource.addIncome(income);

      try {
        final remoteIncome = await remoteDatasource.addIncome(income);
        if (remoteIncome != null) {
          // تحديث الحالة بعد نجاح السيرفر
          remoteIncome.isSynced = true;
          await localDataSource.updateIncome(remoteIncome);
          return Right(remoteIncome);
        }
        return Right(income);
      } catch (e) {
        // ❗ لا نفشل العملية (offline mode)
        debugPrint("Remote Add Failed → Saved Locally: $e");
        return Right(income);
      }
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي: ${e.toString()}"));
    }
  }

  // ================================
  // ✅ GET INCOMES (REMOTE + FALLBACK)
  // ================================
  @override
  Future<Either<Failure, PagedResponse<IncomeModel>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    if (userId == null) return _getLocalPagedIncomes(page);

    try {
      final remoteResponse = await remoteDatasource.getMyIncomes(userId, page);

      // تحديث local cache
      for (var income in remoteResponse.data) {
        income.isSynced = true;
        await localDataSource.addIncome(income);
      }

      return Right(remoteResponse);
    } catch (e) {
      debugPrint("Remote Fetch Failed → Using Local Data: $e");
      return await _getLocalPagedIncomes(page);
    }
  }

  // ================================
  // ✅ UPDATE INCOME
  // ================================
  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeModel income) async {
    try {
      income.isSynced = false;
      await localDataSource.updateIncome(income);

      try {
        final updatedRemote = await remoteDatasource.updateIncome(income);
        if (updatedRemote != null) {
          updatedRemote.isSynced = true;
          await localDataSource.updateIncome(updatedRemote);
          return Left(ServerFailure("فشل التحديث لسبب ما "));
        }
        return const Right(unit);
      } catch (e) {
        debugPrint("Remote Update Failed → Will Sync Later: $e");
        return const Right(unit); // لا نفشل
      }
    } catch (e) {
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  // ================================
  // ✅ DELETE INCOME
  // ================================
  @override
  Future<Either<Failure, Unit>> deleteIncome(IncomeModel income) async {
    try {
      // soft delete
      income.localId = "REMOVE";
      income.isSynced = false;

      await localDataSource.updateIncome(income);

      _safeRemoteCall(() async {
        if (income.remoteId != null) {
          await remoteDatasource.deleteIncome(income);
        }
        await localDataSource.deleteIncome(income);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

  // ================================
  // ✅ SYNC ENGINE (محسن)
  // ================================
  @override
  Future<Either<Failure, Unit>> syncPendingIncomes() async {
    try {
      final allLocal = await localDataSource.getIncomes();

      final pending = allLocal
          .where((i) => i.isSynced != true || i.localId == "REMOVE")
          .toList();

      for (var income in pending) {
        try {
          if (income.localId == "REMOVE") {
            try {
              if (income.remoteId != null) {
                await remoteDatasource.deleteIncome(income);
              }
            } catch (e) {
              debugPrint("Remote delete failed: $e");
              continue;
            }

            await localDataSource.deleteIncome(income);
            continue;
          }

          if (income.remoteId != null) {
            final updated = await remoteDatasource.updateIncome(income);
            if (updated == null) {
              continue;
            }
            updated.isSynced = true;
            await localDataSource.updateIncome(updated);

            continue;
          }

          final created = await remoteDatasource.addIncome(income);
          if (created == null) {
            continue;
          }
          created.isSynced = true;
          await localDataSource.updateIncome(created);
        } catch (e) {
          debugPrint("Sync item failed: $e");
          continue;
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل محرك المزامنة"));
    }
  }

  // ================================
  // ✅ SAFE REMOTE CALL
  // ================================
  Future<void> _safeRemoteCall(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("Silent Sync Error: $e");
    }
  }

  // ================================
  // ✅ LOCAL PAGINATION
  // ================================
  Future<Either<Failure, PagedResponse<IncomeModel>>> _getLocalPagedIncomes(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getIncomes();

      final start = (page.pageNumber - 1) * page.pageSize;
      final end = start + page.pageSize;

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
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

  // ================================
  // ✅ GET ALL LOCAL
  // ================================
  @override
  Future<Either<Failure, List<IncomeModel>>> getAllIncomesLocal() async {
    try {
      final incomes = await localDataSource.getIncomes();
      return Right(incomes);
    } catch (e) {
      return Left(CacheFailure("فشل قراءة البيانات المحلية"));
    }
  }
}
