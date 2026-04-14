import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/splash/introduction.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isWaiting = true;

  @override
  void initState() {
    super.initState();
    // تنفيذ المنطق بعد اكتمال بناء الإطار الأول لتجنب تعليق الـ Navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginAndNavigate();
    });
  }

  Future<void> _checkLoginAndNavigate() async {
    final isLogged = CurrentUser.isUserLoggedIn;

    if (isLogged) {
      // انتظار بسيط لرؤية اللوجو ثم الانتقال
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.MAIN_SCREEN);
    } else {
      if (mounted) {
        setState(() => isWaiting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isWaiting) return Introduction();

    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      body: SizedBox.expand(
        // يملأ كامل مساحة نافذة الويندوز
        child: Center(
          // يضمن توسط المحتوى تماماً
          child: Shimmer.fromColors(
            baseColor: SpColor.surfaceNavy,
            highlightColor: SpColor.accentBlue,
            period: const Duration(milliseconds: 1500),
            child: Image.asset(
              'assets/images/logo3.png',
              width: 280, // عرض ثابت لمنع التمدد المشوه
              fit: BoxFit.contain,
              color: SpColor.accentBlue,
            ),
          ),
        ),
      ),
    );
  }
}
