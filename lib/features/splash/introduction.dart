import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});
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
            SizedBox(
              width: 200,
              child: Image.asset(
                'assets/images/logo3.png',
                color: SpColor.accentBlue,
              ),
            ),
            SizedBox(
              width: 300,
              child: CustomButton(
                onPressed: () {
                  Get.to(
                    () => SignUpPage(),
                    // تأثير الـ fade مع الـ zoom هو الأكثر حداثة ويمنع الوميض تماماً
                    transition: Transition.downToUp,

                    // يمكنك التحكم في السرعة لزيادة النعومة (500 مللي ثانية مثالية)
                    duration: const Duration(milliseconds: 500),
                    // منحنى الحركة يجعل الانتقال يبدو طبيعياً وغير ميكانيكي
                    curve: Curves.fastOutSlowIn,
                  );
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
    );
  }
}
