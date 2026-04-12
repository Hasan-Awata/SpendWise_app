import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';

class SignupUsecase {
  final UserRepository userRepository;

  SignupUsecase(this.userRepository);

  static Future<void> tempUser() async {
    UserModel tempUser = UserModel(
      userId: 1,
      userName: "mohannad",
      firstName: 'mohannad',
      lastName: 'hallah',
    );
    return AppUserLocalDatasourceImpl().registerLocal(tempUser);
  }

  Future<UserEntity> signUp(SignupParams params) async {
    return await userRepository.register(params);
  }
}
