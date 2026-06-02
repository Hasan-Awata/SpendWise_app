import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

class SavingGoalRemoteDatasourceImpl implements SavingGoalRemoteDatasource {
  final NetworkService network;
  SavingGoalRemoteDatasourceImpl({required this.network});

  @override
  Future<PagedResponse<SavingGoalModel>?> getAllUserGoals(
    int userId,
    PageRequest page,
  ) async {
    final result = await network.request(
      endpoint: ApiEndpoints.savingGoalsBase, // مسار GET /api/saving-goals
      method: "GET",
      queryParameters: {
        "pageNumber": page.pageNumber.toString(),
        "pageSize": page.pageSize.toString(),
      },
    );
    return PagedResponse<SavingGoalModel>.fromJson(
      result,
      (json) => SavingGoalModel.fromJson(json),
    );
  }

  @override
  Future<SavingGoalModel> addGoal(SavingGoalModel goal) async {
    print("goal in flutter is ${goal.toJson()}");
    final result = await network.request(
      endpoint: ApiEndpoints.savingGoalsBase, // مسار POST /api/saving-goals
      method: "POST",
      body: goal.toJson(isCreate: true),
    );
    return SavingGoalModel.fromJson(result);
  }

  @override
  Future<SavingGoalModel> updateGoal(SavingGoalModel goal) async {
    final result = await network.request(
      endpoint:
          "${ApiEndpoints.savingGoalsBase}/${goal.goalId}", // مسار PATCH /api/saving-goals/{id}
      method: "PATCH",
      body: goal.toJson(),
    );
    return SavingGoalModel.fromJson(result);
  }

  @override
  Future<bool> deleteGoal(int goalId) async {
    await network.request(
      endpoint:
          "${ApiEndpoints.savingGoalsBase}/$goalId", // مسار DELETE /api/saving-goals/{id}
      method: "DELETE",
    );
    return true;
  }

  @override
  Future<List<SavingGoalModel>> getAchievedGoals(int userId) async {
    final result = await network.request(
      endpoint:
          "${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.getAchievedGoals}", // مسار /api/saving-goals/achieved
      method: "GET",
    );
    return (result as List)
        .map((json) => SavingGoalModel.fromJson(json))
        .toList();
  }

  @override
  Future<SavingGoalModel?> getGoalById(int goalId) async {
    try {
      final result = await network.request(
        endpoint:
            "${ApiEndpoints.savingGoalsBase}/$goalId", // مسار /api/saving-goals/{id}
        method: "GET",
      );
      return SavingGoalModel.fromJson(result);
    } catch (e) {
      return null;
    }
  }
}
