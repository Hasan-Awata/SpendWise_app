import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/presentation/auth_controller.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/presentation/widgets/supwidgets/custom_button.dart';
import 'package:spendwise/presentation/widgets/supwidgets/custom_text_field.dart';
import 'package:spendwise/utils/colors.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  AuthController controller = AuthController.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark,
        title: Text(
          "SignUpPage",
          style: TextStyle(
            color: SpColor.accentBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
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
                label: "First Name",
                hint: "First Name",
                prefixIcon: Icon(Icons.person),
                controller1: controller1,
              ),
              const SizedBox(height: 25),
              CustomTextField(
                label: "Last Name",
                hint: "Last Name",
                prefixIcon: Icon(Icons.person),
                controller1: controller2,
              ),
              const SizedBox(height: 25),
              CustomTextField(
                label: "Email",
                hint: "Email",
                prefixIcon: Icon(Icons.email),
                controller1: controller3,
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

                  controller1: controller4,
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Send",
                onPressed: () {},
                color: SpColor.accentBlue,
              ),
              const SizedBox(height: 80),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SpColor.offWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(LogeIn());
                      },
                      child: Text(
                        " Loge in",
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
