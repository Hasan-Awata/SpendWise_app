import 'package:spendwise/features/auth/domain/usecases/login_params.dart';

class LoginDto {
  final String userName;

  final String password;

  LoginDto({required this.userName, required this.password});

  factory LoginDto.fromParams(LoginParams params) {
    return LoginDto(userName: params.userName, password: params.password);
  }

  Map<String, dynamic> toJson() {
    return {"UserName": userName, "Password": password};
  }
}
