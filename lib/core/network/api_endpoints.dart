// API Endpoints configuration for SpendWise project
class ApiEndpoints {
  static const String baseUrl = "http://www.spendwise.somee.com/api/";
  // static const String baseUrl = "https://192.168.49.1:5999/api/";
  // Auth Endpoints
  // افترضنا أن الـ IP الخاص بك هو 192.168.1.10
  // ]
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

  static const String getAchievedGoals = 'GetAchievedGoals';
}
