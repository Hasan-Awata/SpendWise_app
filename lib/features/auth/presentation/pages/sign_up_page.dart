// // تعليق: واجهة إنشاء حساب جديد - تتضمن التحقق من البيانات والربط مع نظام إدارة الحالة
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/sign_up_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // استدعاء متحكم إنشاء الحساب
  final controller = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.fork_right),
            onPressed: () {
              Get.toNamed('/home');
            },
          ),
        ],
        title: const Text(
          "إنشاء حساب", // Create Account
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
            key: controller
                .signUpFormKey, // مفتاح النموذج للتحقق من صحة المدخلات
            child: Column(
              children: [
                const SizedBox(height: 20),
                // عرض شعار التطبيق
                Image.asset(
                  width: 180,
                  "assets/images/logo.png",
                  color: SpColor.accentBlue.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 40),

                // واجهة المستخدم: حقل الاسم الأول
                CustomTextField(
                  label: "الاسم الأول", // First Name
                  hint: "أدخل الاسم الأول", // Enter first name
                  prefixIcon: const Icon(Icons.person),
                  textEditingController: controller.firstNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "الاسم الأول مطلوب";
                    } else if (value[0].isNum) {
                      return "يجب ألا يبدأ الاسم برقم";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // واجهة المستخدم: حقل اسم العائلة
                CustomTextField(
                  label: "اسم العائلة", // Last Name
                  hint: "أدخل اسم العائلة", // Enter last name
                  prefixIcon: const Icon(Icons.person_outline),
                  textEditingController: controller.lastNameController,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty)) {
                      return "اسم العائلة مطلوب";
                    } else if (value[0].isNum) {
                      return "يجب ألا يبدأ اسم العائلة برقم";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // واجهة المستخدم: حقل اسم المستخدم
                CustomTextField(
                  label: "اسم المستخدم", // User Name
                  hint: "أدخل اسم المستخدم", // Enter User Name
                  prefixIcon: const Icon(Icons.person_add_outlined),
                  textEditingController: controller.signUpUserNameController,
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

                // واجهة المستخدم: حقل كلمة المرور مع خاصية الإخفاء والإظهار
                Obx(
                  () => CustomTextField(
                    label: "كلمة المرور", // Password
                    hint: "أدخل كلمة المرور", // Enter password
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
                    validator: (value) => HelperFunction.validatePassword(
                      value,
                    ), // استخدام دالة مساعدة للتحقق
                  ),
                ),
                const SizedBox(height: 30),

                // زر إنشاء الحساب مع حالة التحميل
                Obx(
                  () => CustomButton(
                    text: "إنشاء حساب", // Sign Up
                    onPressed: () async {
                      await controller.signUp();
                    },
                    color: SpColor.accentBlue,
                    isLoading: controller.isLoadingSignUp.value,
                  ),
                ),
                const SizedBox(height: 80),

                // رابط الانتقال لصفحة تسجيل الدخول إذا كان المستخدم يملك حساباً بالفعل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "لديك حساب بالفعل؟", // Already have an account?
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SpColor.offWhite,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: const Text(
                        " تسجيل الدخول", // Log in
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
