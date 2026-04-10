import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.userId,
    required super.firstName,
    required super.lastName,
    required super.userName,
    super.token,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      userId: json["userId"] ?? 0,
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      userName: json["UserName"] ?? "",
      token: json["Token"] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {"firstName": firstName, "lastName": lastName, "userName": userName};
  }
}
