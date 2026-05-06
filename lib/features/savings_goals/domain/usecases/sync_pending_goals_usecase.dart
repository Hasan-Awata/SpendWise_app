// // تعليق: حالة استخدام مزامنة كافة العمليات المعلقة (إضافة/تعديل) مع الخادم
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';

class SyncPendingGoalsUseCase {
  final SavingGoalRepository repository;

  SyncPendingGoalsUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.syncPendingGoals();
  }
}
