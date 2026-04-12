import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_remote_datasource.dart';

import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/data/repositories/income_repository.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDatasource remoteDatasource;
  final IncomeLocalDataSource localDataSource;

  IncomeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDatasource,
  });

  List<IncomeModel> _pageSlice(List<IncomeModel> all, PageRequest page) {
    final start = (page.pageNumber - 1) * page.pageSize;
    if (start >= all.length) return [];
    final end = start + page.pageSize;
    return all.sublist(start, end > all.length ? all.length : end);
  }

  @override
  Future<void> addIncome(IncomeModel income) async {
    await localDataSource.addIncome(income);
    try {
      await remoteDatasource.addIncome(income);
    } catch (_) {
      // محفوظ محلياً؛ المزامنة لاحقاً — لا نرمي حتى لا يُعرض فشل وهمي في الواجهة
    }
  }

  @override
  Future<List<IncomeModel>> getAllIncomesLocal() async {
    return localDataSource.getIncomes();
  }

  @override
  Future<List<IncomeModel>> getIncomes(int? userId, PageRequest page) async {
    if (userId == null) {
      final localOnly = await localDataSource.getIncomes();
      return _pageSlice(localOnly, page);
    }

    try {
      final remoteIncomes = await remoteDatasource.getMyIncomes(userId, page);

      if (page.pageNumber == 1) {
        final existing = await localDataSource.getIncomes();
        final unsynced = existing.where((e) => e.isSynced != true).toList();
        await localDataSource.clear();
        for (var income in remoteIncomes.data) {
          income.isSynced = true;
          await localDataSource.addIncome(income);
        }
        for (var u in unsynced) {
          await localDataSource.addIncome(u);
        }
      } else {
        for (var income in remoteIncomes.data) {
          income.isSynced = true;
          await localDataSource.addIncome(income);
        }
      }

      return remoteIncomes.data;
    } catch (_) {
      final localIncomes = await localDataSource.getIncomes();
      return _pageSlice(localIncomes, page);
    }
  }

  @override
  Future<void> updateIncome(int incomeId, IncomeModel income) async {
    await localDataSource.updateIncome(income);
    try {
      await remoteDatasource.updateIncome(incomeId, income);
    } catch (_) {}
  }

  @override
  Future<void> deleteIncome(int incomeId) async {
    await localDataSource.deleteIncome(incomeId);
    try {
      await remoteDatasource.deleteIncome(incomeId);
    } catch (_) {}
  }

  Future<void> syncPendingIncomes() async {
    final unsyncedIncomes = await localDataSource.getIncomes();

    for (var income in unsyncedIncomes) {
      try {
        await remoteDatasource.addIncome(income);
        final updateIncome = income;
        updateIncome.isSynced = true;
        localDataSource.updateIncome(updateIncome);
      } catch (_) {
        rethrow;
      }
    }
  }
}
