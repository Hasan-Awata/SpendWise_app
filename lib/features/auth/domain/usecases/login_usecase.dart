import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';

class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase(this.userRepository);

  Future<Either<Failure, UserModel>> login(LoginParams params) async {
    return await userRepository.logIn(params);
  }
}
