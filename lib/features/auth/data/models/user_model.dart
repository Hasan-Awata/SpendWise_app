import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.userId,
    super.firstName,
    super.lastName,
    super.userName,
    required super.token,
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

  @override
  String toString() {
    return 'UserModel(userId: $userId, firstName: $firstName, lastName: $lastName, userName: $userName, token: $token, expiry: $expiry)';
  }
}
