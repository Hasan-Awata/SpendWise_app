import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:spendwise/features/auth/presentation/manager/auth_session_controller.dart';
import 'package:spendwise/features/auth/presentation/manager/login_controller.dart';
import 'package:spendwise/features/auth/presentation/manager/logout_controller.dart';
import 'package:spendwise/features/auth/presentation/manager/sign_up_controller.dart';

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
        () => AppUserRemoteDatasourceImpl(client: http.Client()),
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

    if (!Get.isRegistered<AuthSessionController>()) {
      if (permanentAuthController) {
        Get.put<AuthSessionController>(
          AuthSessionController(
            getUserIdUsecase: Get.find(),
            getUserUsecase: Get.find(),
          ),
          permanent: true,
        );
      } else {
        Get.lazyPut<AuthSessionController>(
          () => AuthSessionController(
            getUserIdUsecase: Get.find(),
            getUserUsecase: Get.find(),
          ),
          fenix: true,
        );
      }
    }

    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController(loginUsecase: Get.find()));
    }
    if (!Get.isRegistered<SignUpController>()) {
      Get.put(SignUpController(signupUsecase: Get.find()));
    }
    if (!Get.isRegistered<LogoutController>()) {
      Get.put(LogoutController(logoutUsecase: Get.find()));
    }
  }
}
