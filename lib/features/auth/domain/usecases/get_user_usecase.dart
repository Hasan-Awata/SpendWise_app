import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';

class GetUserUsecase {
  final UserRepository userRepository;
  GetUserUsecase(this.userRepository);

  Future<Either<Failure, UserModel>> getUser() async {
    return await userRepository.getUser();
  }
}
