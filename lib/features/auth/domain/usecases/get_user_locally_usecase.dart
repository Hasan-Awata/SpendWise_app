import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';

class GetUserLocally {
  UserRepository userRepository;
  GetUserLocally(this.userRepository);

  Future<UserModel?> getUser() async {
    return await userRepository.getUser();
  }
}
