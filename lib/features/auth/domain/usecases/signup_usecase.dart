import 'package:spendwise/features/auth/data/models/user_dto.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class SignupUsecase {
  final UserRepository userRepository;

  SignupUsecase(this.userRepository);

  Future<void> signUp(UserDto userDto) async {
    await userRepository.register(userDto);
  }
}
