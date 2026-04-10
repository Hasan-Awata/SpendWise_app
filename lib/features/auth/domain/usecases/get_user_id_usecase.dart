import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class GetUserIdUsecase {
  final UserRepository userRepository;
  GetUserIdUsecase(this.userRepository);

  Future<int> getUserId() async {
    return userRepository.getUserId();
  }
}
