// // تعليق: واجهة تسجيل الدخول - تدعم التحقق من البيانات، إخفاء/إظهار كلمة المرور، وحالة التحميل
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/login_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class LogInPage extends StatelessWidget {
  // البحث عن متحكم تسجيل الدخول المسجل في الذاكرة
  final controller = Get.find<LoginController>();

  LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "تسجيل الدخول", // Login
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
            key: controller.loginFormKey, // مفتاح النموذج للتحقق من الأخطاء
            child: Column(
              children: [
                const SizedBox(height: 40),
                // عرض شعار التطبيق
                Image.asset(
                  "assets/images/logo.png",
                  width: 180,
                  color: SpColor.accentBlue.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 50),

                // واجهة المستخدم: حقل إدخال اسم المستخدم
                CustomTextField(
                  label: "اسم المستخدم", // User Name
                  hint: "أدخل اسم المستخدم", // Enter User Name
                  prefixIcon: const Icon(Icons.person_add_outlined),
                  textEditingController: controller.loginUserNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "اسم المستخدم مطلوب";
                    } else if (value[0].isNum) {
                      return "يجب ألا يبدأ اسم المستخدم برقم";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // واجهة المستخدم: حقل إدخال كلمة المرور مع خاصية الإظهار/الإخفاء التفاعلية
                Obx(
                  () => CustomTextField(
                    label: "كلمة المرور", // Password
                    hint: "أدخل كلمة المرور", // Enter your password
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

                // زر تسجيل الدخول: يتغير شكله إلى مؤشر تحميل عند معالجة البيانات
                Obx(
                  () => controller.isLoadingLogIn.value
                      ? const CircularProgressIndicator(
                          color: SpColor.accentBlue,
                        )
                      : CustomButton(
                          text: "دخول", // Login
                          onPressed: () async => controller.logIn(),
                          color: SpColor.accentBlue,
                        ),
                ),

                const SizedBox(height: 50),

                // رابط الانتقال لصفحة إنشاء حساب جديد
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ليس لديك حساب بعد؟", // Don't have an account yet?
                      style: TextStyle(color: SpColor.offWhite),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/signup'),
                      child: const Text(
                        " سجل الآن", // Sign up
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
