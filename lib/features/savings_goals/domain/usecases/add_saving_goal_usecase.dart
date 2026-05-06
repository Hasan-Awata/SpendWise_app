// // تعليق: حالة استخدام إضافة هدف ادخار جديد وحفظه محلياً تمهيداً للمزامنة
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';

class AddSavingGoalUseCase {
  final SavingGoalRepository repository;

  AddSavingGoalUseCase(this.repository);

  Future<Either<Failure, String>> call(SavingGoalModel goal) async {
    return await repository.addSavingGoal(goal);
  }
}
