import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase(this.userRepository);

  Future<void> login(String userName, String password) async {
    await userRepository.logIn(userName, password);
  }
}
