// // تعليق: الكود المحدث لشاشة MainScreen مع تصحيح أخطاء الـ Index ومعالجة تسجيل الخروج
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/logout_controller.dart';
import 'package:spendwise/features/home/presentation/pages/home.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/home/presentation/widgets/appbar.dart';
import 'package:spendwise/features/home/presentation/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // استخدام instance الموحد للمتحكم
  final MainController controller = MainController.insatnce;
  final LogoutController logoutController = Get.find<LogoutController>();

  // تعريف قائمة الصفحات - تأكد أنها تطابق عدد العناصر في SPBottomNavBar
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const Home(), // Index 0
      const Center(
        child: Text("Search", style: TextStyle(color: Colors.white)),
      ), // Index 1
      _buildProfilePage(), // Index 2
    ];

    // // تعليق: حماية إضافية - إذا كان الـ index المحفوظ أكبر من عدد الصفحات، نعيده للصفر
    if (controller.currentIndex.value >= pages.length) {
      controller.currentIndex.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B121E),
      appBar: const SPAppbar(),

      // // تعليق: IndexedStack يتطلب أن يكون الـ index ضمن نطاق الـ children
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value < pages.length
              ? controller.currentIndex.value
              : 0,
          children: pages,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.DASHBOARD),
        backgroundColor: SpColor.accentBlue.withOpacity(0.84),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const SPBottomNavBar(),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
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
    );
  }
}
