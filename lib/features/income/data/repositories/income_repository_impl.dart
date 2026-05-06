import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
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

  // ========================= ADD =========================
  @override
  Future<Either<Failure, IncomeModel>> addIncome(IncomeModel income) async {
    final network = NetworkService();
    return await network.saveLocalAndSync<IncomeModel>(
      localSave: () async {
        await localDataSource.addIncome(income);
      },
      remoteSave: () async {
        print("🚀 Sync Income: ${income.localId}");
        income.isSynced = false;

        final result = await remoteDatasource.addIncome(income);

        if (result == null) {
          throw Exception("Remote addIncome returned null");
        }

        return result;
      },
      onSyncSuccess: (remoteIncome) async {
        print("✅ Synced Income: ${remoteIncome.id}");

        remoteIncome.localId = income.localId;
        remoteIncome.isSynced = true;

        await localDataSource.updateIncome(remoteIncome);
      },
      localResult: income,
    );
  }

  // ========================= GET =========================
  @override
  Future<Either<Failure, PagedResponse<IncomeModel>>> getIncomes(
    int? userId,
    PageRequest page,
  ) async {
    try {
      print("📡 Fetching Incomes from Server - Page: ${page.pageNumber}");
      final remoteResponse = await remoteDatasource.getMyIncomes(
        userId ?? 0,
        page,
      );

      for (var model in remoteResponse.data) {
        model.isSynced = true;
        await localDataSource.updateIncome(model);
      }
      return Right(remoteResponse);
    } catch (e) {
      print("🌐 Connection Issue: Switching to Local Storage. Error: $e");

      return await _getLocalPagedIncomes(page);
    }
  }

  // ========================= UPDATE =========================
  @override
  Future<Either<Failure, Unit>> updateIncome(IncomeModel income) async {
    try {
      print("🔄 Updating Income Locally: ${income.id}");

      income.isSynced = false;

      // ✅ Local First
      await localDataSource.updateIncome(income);

      // 🔥 Background Sync
      _safeRemoteCall(() async {
        final updatedRemote = await remoteDatasource.updateIncome(income);

        if (updatedRemote != null) {
          print("✅ Server Update Sync Done");

          updatedRemote.isSynced = true;
          await localDataSource.updateIncome(updatedRemote);
        }
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Update Error: $e");
      return Left(CacheFailure("فشل تحديث البيانات محلياً"));
    }
  }

  // ========================= DELETE =========================
  @override
  Future<Either<Failure, Unit>> deleteIncome(IncomeModel income) async {
    try {
      print("🗑️ Marking Income for Removal: ${income.id}");

      income.localId = "REMOVE";
      income.isSynced = false;

      await localDataSource.updateIncome(income);

      // 🔥 Background Sync
      _safeRemoteCall(() async {
        try {
          if (income.id != null) {
            await remoteDatasource.deleteIncome(income);
            print("✅ Server Delete Done");
          }

          await localDataSource.deleteIncome(income);
        } catch (e) {
          print("⚠️ Remote Delete Failed: $e");
        }
      });

      return const Right(unit);
    } catch (e) {
      print("❌ Local Delete Error: $e");
      return Left(CacheFailure("فشل الحذف المحلي"));
    }
  }

  // ========================= SYNC ENGINE =========================
  @override
  Future<Either<Failure, Unit>> syncPendingIncomes() async {
    try {
      final allLocal = await localDataSource.getIncomes();

      final pending = allLocal
          .where((i) => i.isSynced != true || i.localId == "REMOVE")
          .toList();

      print("🔄 Sync Engine (Income): Found ${pending.length} pending items");

      for (var income in pending) {
        try {
          if (income.localId == "REMOVE") {
            if (income.id != null) {
              await remoteDatasource.deleteIncome(income);
            }

            await localDataSource.deleteIncome(income);

            print("📤 Synced: DELETED Income ${income.id}");
            continue;
          }

          if (income.id != null) {
            final updated = await remoteDatasource.updateIncome(income);

            if (updated != null) {
              updated.isSynced = true;
              await localDataSource.updateIncome(updated);

              print("📤 Synced: UPDATED Income ${income.id}");
            }
          } else {
            final created = await remoteDatasource.addIncome(income);

            if (created != null) {
              created.isSynced = true;
              await localDataSource.updateIncome(created);

              print("📤 Synced: CREATED Income ${created.id}");
            }
          }
        } catch (e) {
          print("⚠️ Sync Error for Income item: $e");
          continue;
        }
      }

      return const Right(unit);
    } catch (e) {
      print("❌ Global Income Sync Failure: $e");
      return Left(CacheFailure("فشل محرك المزامنة"));
    }
  }

  // ========================= LOCAL FALLBACK =========================
  Future<Either<Failure, PagedResponse<IncomeModel>>> _getLocalPagedIncomes(
    PageRequest page,
  ) async {
    try {
      final all = await localDataSource.getIncomes();

      final filtered = all
          .where((i) => i.localId != "REMOVE")
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

      print("📦 Local Incomes Loaded: ${sliced.length} items");

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
      return Left(CacheFailure("خطأ في معالجة البيانات المحلية"));
    }
  }

  // ========================= SAFE REMOTE =========================
  Future<void> _safeRemoteCall(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint("📢 Income Background Sync Info: $e");
    }
  }

  // ========================= LOCAL ONLY =========================
  @override
  Future<Either<Failure, List<IncomeModel>>> getAllIncomesLocal() async {
    try {
      final incomes = await localDataSource.getIncomes();

      return Right(incomes.where((i) => i.localId != "REMOVE").toList());
    } catch (e) {
      return Left(CacheFailure("فشل قراءة البيانات المحلية"));
    }
  }
}
