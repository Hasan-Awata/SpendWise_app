import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final visibility = false.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final signUpFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleSignUpPasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<bool> signUp() async {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    isLoading.value = false;
    return true;
  }

  Future<bool> logIn() async {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    isLoading.value = false;
    return true;
  }

  Future<bool> logOut() async {
    final isValid = signUpFormKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    isLoading.value = false;
    return true;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
