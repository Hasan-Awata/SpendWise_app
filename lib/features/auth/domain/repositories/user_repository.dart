// lib/features/auth/domain/repositories/user_repository.dart

import 'package:dartz/dartz.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> register(SignupParams params);

  Future<Either<Failure, UserModel>> logIn(LoginParams params);

  Future<Either<Failure, Unit>> logOut();

  Future<Either<Failure, UserModel>> getUser();

  Future<Either<Failure, int>> getUserId();
}
