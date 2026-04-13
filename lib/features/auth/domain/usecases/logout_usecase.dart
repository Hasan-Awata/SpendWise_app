import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';

class LogoutUsecase {
  final UserRepository userRepository;

  LogoutUsecase(this.userRepository);

  Future<Either<Failure, Unit>> logout() async {
    return await userRepository.logOut();
  }
}
