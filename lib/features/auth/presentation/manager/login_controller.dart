// // تعليق: تسجيل الدخول فقط
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/login_usecase.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_session_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class LoginController extends GetxController {
  LoginController({required this.loginUsecase});

  final LoginUsecase loginUsecase;

  final loginUserNameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  final isLoginPasswordVisible = false.obs;
  final isLoadingLogIn = false.obs;

  void toggleLoginPasswordVisibility() => isLoginPasswordVisible.toggle();

  Future<void> logIn() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoadingLogIn.value = true;

      final params = LoginParams(
        userName: loginUserNameController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      final result = await loginUsecase.login(params);

      result.fold(
        (failure) {
          print(failure.message);
          HelperFunction.showSnackBar(
            "Login Failed",
            failure.message,
            isError: true,
          );
        },
        (user) async {
          Get.find<AuthSessionController>().currentUser.value = user;

          final prefs = Get.find<SharedPreferencesService>();
          prefs.clear();
          await prefs.setLoggedIn(true);
          await prefs.setToken(user.token);
          HelperFunction.showSnackBar("Success", "Welcome back!");
          Get.offAllNamed('/main-screen');
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "خطأ في السيرفر", isError: true);
      return;
    } finally {
      isLoadingLogIn.value = false;
    }
  }

  @override
  void onClose() {
    loginUserNameController.dispose();
    loginPasswordController.dispose();
    super.onClose();
  }
}
