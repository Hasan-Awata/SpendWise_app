// // تعليق: إنشاء حساب فقط
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_params.dart';
import 'package:spendwise/features/auth/domain/usecases/signup_usecase.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_session_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class SignUpController extends GetxController {
  SignUpController({required this.signupUsecase});

  final SignupUsecase signupUsecase;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final signUpUserNameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpFormKey = GlobalKey<FormState>();

  final isSignUpPasswordVisible = false.obs;
  final isLoadingSignUp = false.obs;

  void toggleSignUpPasswordVisibility() => isSignUpPasswordVisible.toggle();

  Future<void> signUp() async {
    if (!(signUpFormKey.currentState?.validate() ?? false)) return;

    try {
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
          Get.find<AuthSessionController>().currentUser.value = user;

          HelperFunction.showSnackBar(
            "Success",
            "Account created successfully!",
          );
          Get.offAllNamed('/main-screen');
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "خطأ في السيرفر", isError: true);
      return;
    } finally {
      isLoadingSignUp.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    signUpUserNameController.dispose();
    signUpPasswordController.dispose();
    super.onClose();
  }
}
