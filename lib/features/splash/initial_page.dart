import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/splash/introduction.dart';

class InitialPage extends StatefulWidget {
  InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isWaiting = true;
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    final isLogged = CurrentUser.isUserLoggedIn;

    if (isLogged) {
      CurrentUser.initializeUser();

      setState(() {
        isWaiting = true;
      });

      // إعطاء وقت كافٍ للمستخدم لرؤية شعار التطبيق وللنظام لإنهاء الحقن
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;
      Get.offAllNamed(Routes.MAIN_SCREEN);
    } else {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!isWaiting)
        ? Introduction()
        : Container(
            color: SpColor.primaryDark,
            child: Center(
              child: Shimmer.fromColors(
                baseColor: SpColor.surfaceNavy,
                highlightColor: SpColor.accentBlue,
                period: const Duration(milliseconds: 1500),
                child: SizedBox(
                  width: 360,
                  child: Image.asset(
                    'assets/images/logo3.png',
                    color: SpColor.accentBlue,
                  ),
                ),
              ),
            ),
          );
  }
}
