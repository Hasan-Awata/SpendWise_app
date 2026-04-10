class UserEntity {
  final int? userId;
  final String firstName;

  final String lastName;

  final String userName;

  final String? token;

  UserEntity({
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.userId,
    this.token,
  });
}
