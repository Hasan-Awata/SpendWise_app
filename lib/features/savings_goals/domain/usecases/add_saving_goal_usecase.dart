// // تعليق: حالة استخدام إضافة هدف ادخار جديد وحفظه محلياً تمهيداً للمزامنة
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

class AddSavingGoalUseCase {
  final SavingGoalRepository repository;

  AddSavingGoalUseCase(this.repository);

  Future<Either<Failure, String>> call(SavingGoalEntity goal) async {
    return await repository.addSavingGoal(goal);
  }
}
