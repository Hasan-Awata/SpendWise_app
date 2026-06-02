class UserEntity {
  final int userId;
  final String? firstName;

  final String? lastName;

  final String? userName;

  final String token;

  final DateTime? expiry;
  final String? refreshToken;

  UserEntity({
    this.firstName,
    this.lastName,
    this.userName,
    required this.userId,
    required this.token,
    this.expiry,
    this.refreshToken,
  });
}
