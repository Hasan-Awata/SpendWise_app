import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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

  @override
  Future<Either<Failure, Unit>> addIncome(IncomeModel income) async {
    try {
      await localDataSource.addIncome(income);

      _safeRemoteCall(() async {
        final remoteModel = await remoteDatasource.addIncome(income);
        if (remoteModel != null) {
          remoteModel.isSynced = true;
          await localDataSource.updateIncome(remoteModel);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحفظ المحلي"));
    }
  }

  @override
  Future<Either<Failure, PagedResponse<IncomeModel>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    if (userId == null) return _getLocalPagedIncomes(page);

    try {
      final remoteResponse = await remoteDatasource.getMyIncomes(userId, page);

      for (var income in remoteResponse.data) {
        income.isSynced = true;
        await localDataSource.addIncome(income);
      }

      return Right(remoteResponse);
    } catch (e) {
      return await _getLocalPagedIncomes(page);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeModel income) async {
    try {
      income.isSynced = false;
      await localDataSource.updateIncome(income);

      _safeRemoteCall(() async {
        if (income.remoteId != null) {
          await remoteDatasource.updateIncome(income);
          income.isSynced = true;
          await localDataSource.updateIncome(income);
        }
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteIncome(IncomeModel income) async {
    try {
      _safeRemoteCall(() async {
        if (income.remoteId != null)
          await remoteDatasource.deleteIncome(income);
      });

      await localDataSource.deleteIncome(income);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

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
            if (income.remoteId != null)
              await remoteDatasource.deleteIncome(income);
            await localDataSource.deleteIncome(income);
          } else {
            final remoteModel = await remoteDatasource.addIncome(income);
            if (remoteModel != null) {
              remoteModel.isSynced = true;
              await localDataSource.updateIncome(remoteModel);
            }
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

  Future<Either<Failure, PagedResponse<IncomeModel>>> _getLocalPagedIncomes(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getIncomes();
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
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

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
