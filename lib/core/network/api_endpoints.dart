// API Endpoints configuration for SpendWise project
class ApiEndpoints {
  static const String baseUrl = "http://www.spendwise.somee.com/api/";

  // Auth Endpoints
  static const String register = "Authentication/register";
  static const String login = "Authentication/login";
  static const String logout = "auth/logout";

  // Wallet Endpoints
  static const String wallet = "wallets";
  // Income Endpoints
  static const String income = 'Incomes';

  static const String expense = 'Expenses';

  static const String tag = 'tags';
}
