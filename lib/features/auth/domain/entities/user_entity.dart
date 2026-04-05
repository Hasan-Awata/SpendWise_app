import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class UserEntity {
  @HiveField(1)
  final String firstName;
  @HiveField(2)
  final String lastName;
  @HiveField(3)
  final String userName;

  UserEntity({
    required this.firstName,
    required this.lastName,
    required this.userName,
  });
}
