import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource_impl.dart';
import 'package:spendwise/features/auth/domain/repositories/user_repository.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository_impl.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/login_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/logout_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';

class AuthBinding extends Bindings {
  AuthBinding({this.permanentAuthController = false});

  final bool permanentAuthController;

  @override
  void dependencies() {
    if (!Get.isRegistered<AppUserLocalDatasource>()) {
      Get.lazyPut<AppUserLocalDatasource>(() => AppUserLocalDatasourceImpl());
    }
    if (!Get.isRegistered<AppUserRemoteDatasource>()) {
      Get.lazyPut<AppUserRemoteDatasource>(
        () => AppUserRemoteDatasourceImpl(dio: Get.find<Dio>()),
      );
    }
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
        () => UserRepositoryImpl(
          appUserLocalDatasource: Get.find(),
          appUserRemoteDatasource: Get.find(),
        ),
      );
    }
    if (!Get.isRegistered<SignupUsecase>()) {
      Get.lazyPut(() => SignupUsecase(Get.find<UserRepository>()));
    }
    if (!Get.isRegistered<LoginUsecase>()) {
      Get.lazyPut(() => LoginUsecase(Get.find<UserRepository>()));
    }
    if (!Get.isRegistered<LogoutUsecase>()) {
      Get.lazyPut(() => LogoutUsecase(Get.find<UserRepository>()));
    }
    if (!Get.isRegistered<GetUserUsecase>()) {
      Get.lazyPut(() => GetUserUsecase(Get.find<UserRepository>()));
    }
    if (!Get.isRegistered<GetUserIdUsecase>()) {
      Get.lazyPut(() => GetUserIdUsecase(Get.find<UserRepository>()));
    }

    if (!Get.isRegistered<AuthController>()) {
      if (permanentAuthController) {
        Get.put<AuthController>(
          AuthController(
            signupUsecase: Get.find<SignupUsecase>(),
            loginUsecase: Get.find<LoginUsecase>(),
            logoutUsecase: Get.find<LogoutUsecase>(),
            getUserIdUsecase: Get.find<GetUserIdUsecase>(),
            getUserUsecase: Get.find<GetUserUsecase>(),
          ),
          permanent: true,
        );
      } else {
        Get.lazyPut<AuthController>(
          () => AuthController(
            signupUsecase: Get.find<SignupUsecase>(),
            loginUsecase: Get.find<LoginUsecase>(),
            logoutUsecase: Get.find<LogoutUsecase>(),
            getUserIdUsecase: Get.find<GetUserIdUsecase>(),
            getUserUsecase: Get.find<GetUserUsecase>(),
          ),
          fenix: true,
        );
      }
    }
  }
}
