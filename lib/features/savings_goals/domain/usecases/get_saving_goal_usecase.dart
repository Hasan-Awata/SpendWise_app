// // تعليق: حالة استخدام جلب كافة أهداف الادخار الخاصة بالمستخدم مع دعمPagination
import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/repositories/saving_goal_repository.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';

class GetSavingGoalsUseCase {
  final SavingGoalRepository repository;

  GetSavingGoalsUseCase(this.repository);

  Future<Either<Failure, PagedResponse<SavingGoalEntity>>> call(
    int userId,
    PageRequest page,
  ) async {
    return await repository.getMySavingGoals(userId, page);
  }
}
