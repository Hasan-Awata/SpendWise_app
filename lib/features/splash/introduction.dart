import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

class Introduction extends StatefulWidget {
  Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  bool isWaiting = true;
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  void _checkLoginAndNavigate() async {
    final isLogged = await CurrentUser.isUserLoggedIn;

    if (isLogged) {
      isWaiting = true;

      await Future.delayed(const Duration(seconds: 6));
      Get.offAllNamed(Routes.MAIN_SCREEN);
    } else {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* يعرض شعار التطبيق في منتصف الشاشة */
            if (!isWaiting)
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 340,
                      child: Image.asset(
                        'assets/images/logo3.png',
                        color: SpColor.accentBlue,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: CustomButton(
                        onPressed: () {
                          Get.toNamed('/login');
                        },
                        text: "Continue",
                        color: SpColor.accentBlue,
                        shadowColor: SpColor.accentBlue,
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
            if (isWaiting)
              Shimmer.fromColors(
                baseColor: SpColor.surfaceNavy,
                highlightColor: SpColor.accentBlue,
                period: Duration(milliseconds: 1500),
                child: SizedBox(
                  width: 360,
                  child: Image.asset(
                    'assets/images/logo3.png',
                    color: SpColor.accentBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
