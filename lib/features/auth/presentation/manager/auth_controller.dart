import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/domain/entities/user_entity.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_usecase.dart';
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
  final GetUserUsecase getUserUsecase;
  AuthController({
    required this.signupUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getUserIdUsecase,
    required this.getUserUsecase,
  });

  static AuthController get instance => Get.find<AuthController>();

  // === UI Fields ===
  final loginUserNameController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final signUpUserNameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpFormKey = GlobalKey<FormState>();

  // === State Observables ===
  final isLoginPasswordVisible = false.obs;
  final isSignUpPasswordVisible = false.obs;
  final isLoadingSignUp = false.obs;
  final isLoadingLogIn = false.obs;
  final isLoadingLogOut = false.obs;

  // استخدام Rxn للسماح بالقيمة null في البداية
  final Rxn<UserEntity> currentUser = Rxn<UserEntity>();

  void toggleSignUpPasswordVisibility() => isSignUpPasswordVisible.toggle();
  void toggleLoginPasswordVisibility() => isLoginPasswordVisible.toggle();

  // === Functions ===

  Future<void> signUp() async {
    if (!(signUpFormKey.currentState?.validate() ?? false)) return;

    isLoadingSignUp.value = true;

    final params = SignupParams(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      userName: signUpUserNameController.text.trim(),
      password: signUpPasswordController.text.trim(),
    );

    final result = await signupUsecase.signUp(params);

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "Sign Up Failed",
          failure.message,
          isError: true,
        );
      },
      (user) async {
        currentUser.value = user;
        final prefs = Get.find<SharedPreferencesService>();
        await prefs.setLoggedIn(true);
        await prefs.setToken(user.token);
        HelperFunction.showSnackBar("Success", "Account created successfully!");
        Get.offAllNamed('/main-screen');
      },
    );

    isLoadingSignUp.value = false;
  }

  Future<void> logIn() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

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
        currentUser.value = user;
        final prefs = Get.find<SharedPreferencesService>();
        await prefs.setLoggedIn(true);
        await prefs.setToken(user.token);
        HelperFunction.showSnackBar("Success", "Welcome back!");
        Get.offAllNamed('/main-screen');
      },
    );

    isLoadingLogIn.value = false;
  }

  Future<void> logOut() async {
    isLoadingLogOut.value = true;

    final result = await logoutUsecase.logout();

    result.fold(
      (failure) => HelperFunction.showSnackBar(
        "Logout Failed",
        failure.message,
        isError: true,
      ),
      (_) {
        currentUser.value = null;
        HelperFunction.showSnackBar("Success", "Logged out successfully");
        Get.offAllNamed('/login'); // الانتقال لصفحة التسجيل
      },
    );

    isLoadingLogOut.value = false;
  }

  Future<void> fetchUserId() async {
    final result = await getUserIdUsecase.getUserId();
    result.fold((failure) => null, (id) => print("User ID: $id"));
  }

  Future<void> getUser() async {
    final result = await getUserUsecase.getUser();
    result.fold((failure) => null, (user) => currentUser.value = user);
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
