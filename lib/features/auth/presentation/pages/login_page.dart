import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/login_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class LogInPage extends StatelessWidget {
  final controller = Get.find<LoginController>();
  LogInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Login",
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
            key: controller.loginFormKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  "assets/images/logo.png",
                  width: 180,
                  color: SpColor.accentBlue.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  label: "User Name",
                  hint: "Enter User Name",
                  prefixIcon: const Icon(Icons.person_add_outlined),
                  textEditingController: controller.loginUserNameController,
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
                    hint: "Enter your password",
                    obscureText: !controller.isLoginPasswordVisible.value,
                    textEditingController: controller.loginPasswordController,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: controller.toggleLoginPasswordVisibility,
                      icon: Icon(
                        controller.isLoginPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: SpColor.accentBlue,
                      ),
                    ),
                    validator: (value) =>
                        HelperFunction.validatePassword(value),
                  ),
                ),

                const SizedBox(height: 40),

                // زر تسجيل الدخول مع مراقبة حالة التحميل
                Obx(
                  () => controller.isLoadingLogIn.value
                      ? const CircularProgressIndicator(
                          color: SpColor.accentBlue,
                        )
                      : CustomButton(
                          text: "Login",
                          onPressed: () => controller.logIn(),
                          color: SpColor.accentBlue,
                        ),
                ),

                const SizedBox(height: 50),

                // رابط الانتقال لإنشاء حساب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account yet?",
                      style: TextStyle(color: SpColor.offWhite),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: const Text(
                        " Sign up",
                        style: TextStyle(
                          color: SpColor.accentBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
