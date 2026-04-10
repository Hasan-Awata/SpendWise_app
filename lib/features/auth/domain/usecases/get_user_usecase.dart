import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';

class GetUserUsecase {
  final UserRepository userRepository;
  GetUserUsecase(this.userRepository);

  Future<UserEntity?> getUser() async {
    return await userRepository.getUser();
  }
}
