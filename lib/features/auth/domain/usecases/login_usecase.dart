import 'package:spendwise/features/auth/data/models/user_dto.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase(this.userRepository);

  Future<UserModel> login(String userName, String password) async {
    final response = await userRepository.logIn(userName, password);
    await userRepository.registerLocal(response);
    return response;
  }
}
