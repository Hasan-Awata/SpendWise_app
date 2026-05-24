// API Endpoints configuration for SpendWise project
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/helper_function.dart';

class ApiEndpoints {
  // static const String baseUrl = "http://www.spendwise.somee.com/api/";
  // static const String baseUrl = "https://192.168.49.1:5999/api/";
  // Auth Endpoints
  // افترضنا أن الـ IP الخاص بك هو 192.168.1.10
  //
  static const String baseUrl = "http://localhost:5254/api/";
  static const String register = "Authentication/register";
  static const String login = "Authentication/login";
  static const String logout = "auth/logout";

  // Wallet Endpoints
  static const String wallet = "wallets";
  // Income Endpoints
  static const String income = 'incomes';

  static const String expense = 'Expenses';

  static const String tag = 'tags';

  static const String savingGoalsBase = 'Saving_Goal';

  static const String getGoalById = 'GetGoalByID';

  static const String getAllUserGoals = 'GetAllUserGoals';

  static const String addGoal = 'AddGoal';

  static const String updateGoal = 'UpdateGoal';

  static const String deleteGoal = 'DeleteGoal';
  static const String categories = 'categories';

  static const String getAchievedGoals = 'GetAchievedGoals';
  static const String transactions = "transactions";

  Future<Map<String, String>?> getHeaders() async {
    try {
      final userSource = Get.find<AppUserLocalDatasource>();
      final user = await userSource.getUser();
      final id = userSource.getUserId();

      final String? token;
      if (user != null) {
        token = user.token;
        print("$id ---- ${user.token}");
      } else {
        return null;
      }
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      HelperFunction.showSnackBar("Error Auth", e.toString());
      return null;
    }
  }
}
