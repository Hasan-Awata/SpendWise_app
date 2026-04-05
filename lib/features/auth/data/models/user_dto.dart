class UserDto {
  final String firstName;

  final String lastName;

  final String userName;

  final String password;

  UserDto({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "userName": userName,
      "password": password,
    };
  }
}
