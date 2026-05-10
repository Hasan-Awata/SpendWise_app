// // [تنبيه: تم تحديث الروابط لتتوافق مع ApiEndpoints الجديدة التي تعتمد على المسارات الفرعية للـ Controller]

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/pages/data/model/page_response.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_remote_datasource.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';

class SavingGoalRemoteDatasourceImpl implements SavingGoalRemoteDatasource {
  final http.Client client;
  final Duration timeoutDuration = const Duration(seconds: 7);

  SavingGoalRemoteDatasourceImpl({required this.client});

  @override
  Future<PagedResponse<SavingGoalModel>> getAllUserGoals(
    int userId,
    PageRequest page,
  ) async {
    // // تعديل: استخدام savingGoalsBase مع getAllUserGoals
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.getAllUserGoals}",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final goals = data
            .map((json) => SavingGoalModel.fromJson(json))
            .toList();

        return PagedResponse<SavingGoalModel>(
          data: goals,
          totalRecords: goals.length,
          pageNumber: page.pageNumber,
          pageSize: page.pageSize,
          totalPages: 1,
        );
      } else {
        throw Exception(
          "فشل جلب أهداف الادخار: رمز الحالة ${response.statusCode}",
        );
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة الاتصال، يرجى التحقق من الإنترنت");
    }
  }

  @override
  Future<SavingGoalModel> addGoal(SavingGoalModel goal) async {
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.addGoal}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(goal.toJson());

    try {
      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // في الـ Backend يعود الـ ID فقط أحياناً، تأكد من معالجة الرد حسب الـ Controller الخاص بك
        return SavingGoalModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل إضافة الهدف: ${response.body}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة الطلب، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<SavingGoalModel> updateGoal(SavingGoalModel goal) async {
    // // تعديل: تمرير الـ ID في المسار كما هو محدد في [HttpPatch("UpdateGoal/{goalID}")]
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.updateGoal}/${goal.goalId}",
    );
    final headers = await ApiEndpoints().getHeaders();
    final body = jsonEncode(goal.toJson());

    try {
      final response = await client
          .patch(url, headers: headers, body: body)
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SavingGoalModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("فشل تحديث الهدف: رمز الحالة ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("انتهت مهلة التحديث، يرجى المحاولة لاحقاً");
    }
  }

  @override
  Future<bool> deleteGoal(int goalId) async {
    // // تعديل: استخدام deleteGoal مع الـ ID في المسار
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.deleteGoal}/$goalId",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .delete(url, headers: headers)
          .timeout(timeoutDuration);
      return response.statusCode == 200 || response.statusCode == 204;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SavingGoalModel?> getGoalById(int goalId) async {
    // // تعديل: استخدام getGoalById مع الـ ID في المسار
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.getGoalById}/$goalId",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SavingGoalModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SavingGoalModel>> getAchievedGoals(int userId) async {
    // // تعديل: استخدام getAchievedGoals
    final url = Uri.parse(
      "${ApiEndpoints.baseUrl}${ApiEndpoints.savingGoalsBase}/${ApiEndpoints.getAchievedGoals}",
    );
    final headers = await ApiEndpoints().getHeaders();

    try {
      final response = await client
          .get(url, headers: headers)
          .timeout(timeoutDuration);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SavingGoalModel.fromJson(json)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
