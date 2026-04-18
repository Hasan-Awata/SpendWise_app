import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

class Introduction extends StatelessWidget {
  Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      body: Center(
        child: SingleChildScrollView(
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
                  text: "استمرار",

                  color: SpColor.accentBlue,
                  shadowColor: SpColor.accentBlue,
                  isLoading: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
