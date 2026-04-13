class ApiEndpoints {
  static const String baseUrl = "http://www.spendwise.somee.com/api/";
  // Auth Endpoints
  static const String register = "Authentication/register";
  static const String login = "Authentication/login";
  static const String logout = "auth/logout";
  static const String addWallet = "wallet/add";
  static const String getWallets = "wallet/get";
  static const String addIncome = 'Incomes/AddIncome';
  static const String updateIncome = 'Incomes/updateIncome';
  static const String deleteIncome = 'Incomes/deleteIncome';
  static const String getIncomeByUser = 'Income/GetIncomeByUser';
}
