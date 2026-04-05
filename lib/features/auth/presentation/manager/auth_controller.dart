import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/features/auth/data/models/user_dto.dart';
import 'package:spendwise/features/auth/domain/usecases/login_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/logout_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';
import 'package:spendwise/features/helper_function.dart';

class AuthController extends GetxController {
  final SignupUsecase signupUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;

  // 2. المشيد (Constructor) لاستقبال الـ UseCases المحقونة من الـ Binding
  AuthController({
    required this.signupUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
  });

  static AuthController get instance => Get.find<AuthController>();

  // === Login Fields ===
  final loginUserNameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final isLoginPasswordVisible = false.obs;
  final isLoadingLogIn = false.obs;
  // === SignUp Fields ===
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final signUpUserNameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpFormKey = GlobalKey<FormState>();
  final isSignUpPasswordVisible = false.obs;
  final isLoadingSignUp = false.obs;

  final isLoadingLogOut = false.obs;

  void toggleSignUpPasswordVisibility() {
    isSignUpPasswordVisible.value = !isSignUpPasswordVisible.value;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  Future<bool> signUp() async {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return false;
    try {
      isLoadingSignUp.value = true;

      final userDto = UserDto(
        firstName: signUpPasswordController.text.trim(),
        lastName: lastNameController.text.trim(),
        userName: signUpUserNameController.text.trim(),
        password: signUpPasswordController.text.trim(),
      );
      await signupUsecase.signUp(userDto);
      HelperFunction.showSnackBar("Success", "Account created successfully!");
      return true;
    } catch (e) {
      HelperFunction.showSnackBar(
        "Sign Up Failed",
        "Faild process",
        isError: true,
      );
      return false;
    } finally {
      // 6. إغلاق حالة التحميل في كل الأحوال (نجاح أو فشل)
      isLoadingSignUp.value = false;
    }
  }

  Future<bool> logIn() async {
    final isValid = loginFormKey.currentState?.validate() ?? false;
    if (!isValid) return false;
    try {
      isLoadingLogIn.value = true;
      await loginUsecase.login(
        loginUserNameController.text.trim(),
        loginPasswordController.text.trim(),
      );
      HelperFunction.showSnackBar("Success", "LogIn");
      return true;
    } catch (e) {
      HelperFunction.showSnackBar(
        "LogIn Failed",
        "Faild process",
        isError: true,
      );
      return false;
    } finally {
      isLoadingLogIn.value = false;
    }
  }

  Future<bool> logOut() async {
    try {
      isLoadingLogOut.value = true;
      await logoutUsecase.logout();
      HelperFunction.showSnackBar("Success", "LogOut");
      return true;
    } catch (e) {
      HelperFunction.showSnackBar("Faild", "LogOut");
      return false;
    } finally {
      isLoadingLogOut.value = false;
    }
  }

  @override
  void onClose() {
    loginUserNameController.dispose();
    loginPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    signUpUserNameController.dispose();
    signUpPasswordController.dispose();
    super.onClose();
  }
}
