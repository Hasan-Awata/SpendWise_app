import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.firstName,
    required super.lastName,
    required super.userName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json["firstName"],
      lastName: json["lastName"],
      userName: json["userName"],
    );
  }
  Map<String, dynamic> toJson() {
    return {"firstName": firstName, "lastName": lastName, "userName": userName};
  }
}
