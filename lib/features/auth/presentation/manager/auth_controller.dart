import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/login_params.dart';
import 'package:spendwise/features/auth/domain/usecases/login_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/logout_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';
import 'package:spendwise/features/helper_function.dart';

class AuthController extends GetxController {
  final SignupUsecase signupUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetUserIdUsecase getUserIdUsecase;

  // 2. المشيد (Constructor) لاستقبال الـ UseCases المحقونة من الـ Binding
  AuthController({
    required this.signupUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getUserIdUsecase,
  });

  AppUserLocalDatasourceImpl local = AppUserLocalDatasourceImpl();
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

  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);

  void toggleSignUpPasswordVisibility() {
    isSignUpPasswordVisible.value = !isSignUpPasswordVisible.value;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  Future<void> signUp() async {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return;
    try {
      isLoadingSignUp.value = true;

      final userParams = SignupParams(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userName: signUpUserNameController.text.trim(),
        password: signUpPasswordController.text.trim(),
      );

      final user = await signupUsecase.signUp(userParams);

      local.registerLocal(
        UserModel(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          userName: signUpUserNameController.text.trim(),
          token: user.token,
        ),
      );
      currentUser.value = UserModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userName: signUpUserNameController.text.trim(),
      );

      HelperFunction.showSnackBar("Success", "Account created successfully!");
      Get.offAllNamed('/main-screen');
    } catch (e) {
      HelperFunction.showSnackBar(
        "Sign Up Failed",
        e.toString(),
        isError: true,
      );
    } finally {
      // 6. إغلاق حالة التحميل في كل الأحوال (نجاح أو فشل)
      isLoadingSignUp.value = false;
    }
  }

  Future<void> logIn() async {
    final isValid = loginFormKey.currentState?.validate() ?? false;
    if (!isValid) return;
    try {
      isLoadingLogIn.value = true;

      final userParams = LoginParams(
        userName: loginUserNameController.text.trim(),
        password: loginPasswordController.text.trim(),
      );
      final user = await loginUsecase.login(userParams);
      currentUser.value = user;
      HelperFunction.showSnackBar("Success", "LogIn");
      Get.offAllNamed('/main-screen');
    } catch (e) {
      HelperFunction.showSnackBar(
        "LogIn Failed",
        "Faild process",
        isError: true,
      );
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

  Future<int> userId() async {
    return await getUserIdUsecase.getUserId();
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
