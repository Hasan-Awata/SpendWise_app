import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.userId,
    super.firstName,
    super.lastName,
    super.userName,
    super.token,
    super.expiry,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      token: json["Token"] ?? "",
      userName: json["UserName"] ?? "",
      expiry: json["Expiry"] ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {"FirstName": firstName, "LastName": lastName, "UserName": userName};
  }
}
