// تعليق: تعديل ملف روابط الـ API لتتوافق تماماً مع روابط الـ Controller بعد تنظيفها من المتغيرات الزائدة والمشوهة في الـ المسار (Routes)
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/helper_function.dart';

class ApiEndpoints {
  // static const String baseUrl = "http://www.spendwise.somee.com/api/";
  // static const String baseUrl = "https://192.168.49.1:5999/api/";

  static const String baseUrl = "http://localhost:5254/api/";

  // Auth Endpoints
  static const String register = "Authentication/register";
  static const String login = "Authentication/login";
  static const String logout = "auth/logout";

  // Wallet Endpoints
  static const String wallet = "wallets";

  // Income Endpoints
  static const String income = 'incomes';

  // Expense Endpoints
  static const String expense = 'expenses';

  // Tag Endpoints
  static const String tag = 'tags';

  // Saving Goals Endpoints
  // ملاحظة: المسار الأساسي هو saving-goals
  static const String savingGoalsBase = 'saving-goals';

  // الـ Controller يستخدم [HttpGet("{id}")]
  static const String getGoalById = ''; // سيتم دمجها مع /api/saving-goals/{id}

  // الـ Controller يستخدم [HttpGet] بدون مسار إضافي
  static const String getAllUserGoals = '';

  // الـ Controller يستخدم [HttpPost] بدون مسار إضافي
  static const String addGoal = '';

  // الـ Controller يستخدم [HttpPatch("{goalId}")]
  static const String updateGoal = '';

  // الـ Controller يستخدم [HttpDelete("{goalId}")]
  static const String deleteGoal = '';

  static const String getAchievedGoals = 'achieved';

  static const String categories = 'categories/budgets';
  static const String transactions = "transactions";
  static const String refreshToken = "Authentication/refresh";

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
