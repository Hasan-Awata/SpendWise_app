import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_remote_datasource_impl.dart';

import 'package:spendwise/features/auth/data/repositories/user_repository.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository_impl.dart';
import 'package:spendwise/features/auth/domain/usecases/login_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/logout_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ),
    );
    Get.lazyPut<AppUserLocalDatasource>(() {
      final datasource = AppUserLocalDatasourceImpl();
      datasource.init();
      return datasource;
    });
    Get.lazyPut<AppUserRemoteDatasource>(
      () => AppUserRemoteDatasourceImpl(dio: Get.find()),
    );
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(
        appUserLocalDatasource: Get.find(),
        // تأكد أن UserRepositoryImpl يستقبل Remote أيضاً في مشيده
        appUserRemoteDatasource: Get.find(),
      ),
    );
    Get.lazyPut(() => SignupUsecase(Get.find<UserRepository>()));
    Get.lazyPut(() => LoginUsecase(Get.find<UserRepository>()));
    Get.lazyPut(() => LogoutUsecase(Get.find<UserRepository>()));
    Get.put(
      AuthController(
        signupUsecase: Get.find(),
        loginUsecase: Get.find(),
        logoutUsecase: Get.find(),
      ),
    );
  }
}
