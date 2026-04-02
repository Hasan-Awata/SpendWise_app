import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/auth_controller.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class LogeIn extends StatefulWidget {
  const LogeIn({super.key});

  @override
  State<LogeIn> createState() => _LogeInState();
}

class _LogeInState extends State<LogeIn> {
  AuthController controller = AuthController.instance;

  TextEditingController textEditingController = TextEditingController();

  TextEditingController controller2 = TextEditingController();

  TextEditingController controller3 = TextEditingController();

  TextEditingController controller4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        title: const Text(
          "LogeIn",
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
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
                label: "Email",
                hint: "Email",
                prefixIcon: const Icon(Icons.email),
                textEditingController: controller3,
              ),
              const SizedBox(height: 25),
              Obx(
                () => CustomTextField(
                  label: "Password",
                  hint: "Password",
                  obscureText: controller.visibility.value ? true : false,
                  prefixIcon: IconButton(
                    onPressed: () {
                      controller.visibility.value =
                          !controller.visibility.value;
                    },
                    icon: Icon(
                      controller.visibility.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: SpColor.accentBlue,
                    ),
                  ),
                  textEditingController: controller4,
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Send",
                onPressed: () {
                  Get.to(() => const MainScreen());
                },
                color: SpColor.accentBlue,
              ),
              const SizedBox(height: 80),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SpColor.offWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => SignUpPage());
                      },
                      child: Text(
                        " Sign up",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: SpColor.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
