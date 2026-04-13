import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

class SignupDto {
  final String firstName;

  final String lastName;

  final String userName;

  final String password;

  SignupDto({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
  });

  factory SignupDto.fromParams(SignupParams params) {
    return SignupDto(
      firstName: params.firstName,
      lastName: params.lastName,
      userName: params.userName,
      password: params.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "UserName": userName,
      "Password": password,
    };
  }
}
