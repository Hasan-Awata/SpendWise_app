import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final controller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.fork_right),
            onPressed: () {
              Get.to(() => MainScreen());
            },
          ),
        ],
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: controller.signUpFormKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  width: 180,
                  "assets/images/logo.png",
                  color: SpColor.accentBlue.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: "First Name",
                  hint: "Enter first name",
                  prefixIcon: const Icon(Icons.person),
                  textEditingController: controller.firstNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "First name is required";
                    } else if (value[0].isNum) {
                      return "First Name mustn't start in number ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  label: "Last Name",
                  hint: "Enter last name",
                  prefixIcon: const Icon(Icons.person_outline),
                  textEditingController: controller.lastNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "Last name is required";
                    } else if (value[0].isNum) {
                      return "Last Name mustn't start in number ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  label: "User Name",
                  hint: "Enter User Name",
                  prefixIcon: const Icon(Icons.person_add_outlined),
                  textEditingController: controller.signUpUserNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "User Name is required";
                    } else if (value[0].isNum) {
                      return "User Name mustn't start in number ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Obx(
                  () => CustomTextField(
                    label: "Password",
                    hint: "Enter password",
                    obscureText: !controller.isSignUpPasswordVisible.value,
                    prefixIcon: IconButton(
                      onPressed: controller.toggleSignUpPasswordVisibility,
                      icon: Icon(
                        controller.isSignUpPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: SpColor.accentBlue,
                      ),
                    ),
                    textEditingController: controller.signUpPasswordController,
                    validator: (value) =>
                        HelperFunction.validatePassword(value),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(
                  () => CustomButton(
                    text: "Sign Up",
                    onPressed: () async {
                      final success = await controller.signUp();
                      if (success) {
                        Get.offAll(() => const MainScreen());
                      }
                    },
                    color: SpColor.accentBlue,
                    isLoading: controller.isLoadingSignUp.value,
                  ),
                ),
                const SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SpColor.offWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: const Text(
                        " Log in",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SpColor.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
