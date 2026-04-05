import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';

class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase(this.userRepository);

  Future<UserEntity> login(LoginParams params) async {
    return await userRepository.logIn(params);
  }
}
