// // تعليق: حالة استخدام جلب كافة أهداف الادخار الخاصة بالمستخدم مع دعمPagination
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';

class GetSavingGoalsUseCase {
  final SavingGoalRepository repository;

  GetSavingGoalsUseCase(this.repository);

  Future<Either<Failure, PagedResponse<SavingGoalModel>>> call(
    int userId,
    PageRequest page,
  ) async {
    return await repository.getMySavingGoals(userId, page);
  }
}
