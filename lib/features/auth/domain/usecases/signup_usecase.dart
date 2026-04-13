import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

class SignupUsecase {
  final UserRepository userRepository;

  SignupUsecase(this.userRepository);

  Future<Either<Failure, UserModel>> signUp(SignupParams params) async {
    return await userRepository.register(params);
  }
}
