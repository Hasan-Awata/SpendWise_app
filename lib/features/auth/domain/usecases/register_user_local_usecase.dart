import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class RegisterUserLocalUsecase {
  UserRepository userRepository;
  RegisterUserLocalUsecase(this.userRepository);

  Future<void> registerLocal(UserModel user) async {
    await userRepository.registerLocal(user);
  }
}
