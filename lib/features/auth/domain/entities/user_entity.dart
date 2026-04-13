class UserEntity {
  final int? userId;
  final String? firstName;

  final String? lastName;

  final String? userName;

  final String? token;

  final DateTime? expiry;

  UserEntity({
    this.firstName,
    this.lastName,
    this.userName,
    this.userId,
    this.token,
    this.expiry,
  });
}
