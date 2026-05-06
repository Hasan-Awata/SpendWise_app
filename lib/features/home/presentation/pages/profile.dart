import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/logout_controller.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final MainController controller = MainController.instance;
  final LogoutController logoutController = Get.find<LogoutController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          SizedBox(height: 40),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: SpColor.surfaceNavy),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () async {
                  Get.defaultDialog(
                    title: "تسجيل الخروج",
                    middleText: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                    backgroundColor: const Color(0xFF162030),
                    titleStyle: const TextStyle(color: Colors.white),
                    middleTextStyle: const TextStyle(color: Colors.white70),
                    textConfirm: "نعم",
                    textCancel: "إلغاء",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.redAccent,
                    onConfirm: () async {
                      // // تعليق: إغلاق الحوار وتصفير الـ index قبل تسجيل الخروج
                      Get.back();
                      controller.currentIndex.value = 0;
                      await logoutController.logOut();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
