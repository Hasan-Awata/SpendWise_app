import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

class SignupUsecase {
  final UserRepository userRepository;

  SignupUsecase(this.userRepository);

  Future<UserEntity> signUp(SignupParams params) async {
    return await userRepository.register(params);
  }
}
