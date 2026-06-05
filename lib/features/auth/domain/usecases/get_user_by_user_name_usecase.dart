import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';

class GetUserByUsernameUseCase {
  final UserRepository repository;

  GetUserByUsernameUseCase(this.repository);

  Future<Either<Failure, UserModel>> call(String username) async {
    return await repository.getUserByUsername(username);
  }
}
