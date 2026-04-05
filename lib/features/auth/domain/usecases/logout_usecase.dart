import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class LogoutUsecase {
  final UserRepository userRepository;

  LogoutUsecase(this.userRepository);

  Future<void> logout() async {
    await userRepository.logOut();
  }
}
