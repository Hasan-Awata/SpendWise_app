import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final AuthController controller = AuthController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "First name is required"
                      : null,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  label: "Last Name",
                  hint: "Enter last name",
                  prefixIcon: const Icon(Icons.person_outline),
                  textEditingController: controller.lastNameController,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "Last name is required"
                      : null,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  label: "Email",
                  hint: "Enter email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  textEditingController: controller.emailController,
                  validator: (value) =>
                      (value == null || !GetUtils.isEmail(value.trim()))
                      ? "Enter a valid email"
                      : null,
                ),
                const SizedBox(height: 25),
                Obx(
                  () => CustomTextField(
                    label: "Password",
                    hint: "Enter password",
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: IconButton(
                      onPressed: controller.toggleSignUpPasswordVisibility,
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: SpColor.accentBlue,
                      ),
                    ),
                    textEditingController: controller.passwordController,
                    validator: (value) => (value == null || value.length < 6)
                        ? "Minimum 6 characters"
                        : null,
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
                    isLoading: controller.isLoading.value,
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
                      onTap: () => Get.to(() => const LogeIn()),
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
