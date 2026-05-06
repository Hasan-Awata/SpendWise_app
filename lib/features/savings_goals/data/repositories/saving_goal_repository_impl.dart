// // تعليق: تنفيذ المستودع مع تطبيق استراتيجية المزامنة في الخلفية والتعامل مع الأخطاء المحلية والشبكية
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';

import '../datasources/saving_goal_remote_datasource.dart';
import '../models/saving_goal_model.dart';
import '../repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalRemoteDatasource remoteDatasource;
  final SavingGoalLocalDatasource localDatasource;

  SavingGoalRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, String>> addSavingGoal(SavingGoalModel goal) async {
    final network = NetworkService();
    return await network.saveLocalAndSync<String>(
      localSave: () async {
        await localDatasource.updateGoalLocal(goal);
      },
      remoteSave: () async {
        final result = await remoteDatasource.addGoal(goal);

        return result.title;
      },
      onSyncSuccess: (_) async {
        goal.isSynced = true;
        await localDatasource.updateGoalLocal(goal);
      },
      localResult: "تم الحفظ محلياً",
    );
  }

  @override
  Future<Either<Failure, PagedResponse<SavingGoalModel>>> getMySavingGoals(
    int userId,
    PageRequest page,
  ) async {
    try {
      final remoteResponse = await remoteDatasource.getAllUserGoals(
        userId,
        page,
      );

      for (var goal in remoteResponse.data) {
        goal.isSynced = true;
        await localDatasource.updateGoalLocal(goal);
      }
      return Right(remoteResponse);
    } catch (e) {
      // في حال فشل الإنترنت، جلب البيانات من Hive
      final localData = await localDatasource.getAllGoalsLocal();
      return Right(
        PagedResponse(
          data: localData,
          totalRecords: localData.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSavingGoal(SavingGoalModel goal) async {
    try {
      goal.isSynced = false;
      await localDatasource.updateGoalLocal(goal);

      _safeRemoteCall(() async {
        final remote = await remoteDatasource.updateGoal(goal);
        remote.isSynced = true;
        await localDatasource.updateGoalLocal(remote);
      });

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل التحديث المحلي"));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSavingGoal(SavingGoalModel goal) async {
    try {
      if (goal.goalId != null && goal.goalId! > 0) {
        _safeRemoteCall(
          () async => await remoteDatasource.deleteGoal(goal.goalId!),
        );
      }
      await localDatasource.deleteGoalLocal(goal.localId!);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure("فشل الحذف"));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncPendingGoals() async {
    // منطق مشابه لـ WalletRepository لمزامنة ما لم يتم رفعه
    return const Right(unit);
  }

  Future<void> _safeRemoteCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<SavingGoalModel>>> getAchievedGoals(
    int userId,
  ) async {
    try {
      final goals = await remoteDatasource.getAchievedGoals(userId);
      return Right(goals);
    } catch (e) {
      return Left(ServerFailure("فشل جلب الأهداف المحققة"));
    }
  }
}
