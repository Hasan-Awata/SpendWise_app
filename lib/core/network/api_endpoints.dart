class ApiEndpoints {
  static const String baseUrl = "http://10.0.2.2:8080/api/v1";
  // Auth Endpoints
  static const String register = "/api/Authentication/register";
  static const String login = "/api/Authentication/login";
  static const String logout = "/auth/logout";
  static const String addWallet = "/api/wallet/add";
  static const String getWallets = "/api/wallet/get";
}
