import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/home/presentation/pages/home.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/home/presentation/widgets/appbar.dart';
import 'package:spendwise/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:spendwise/features/dashboard/presentation/pages/dashboard_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainController controller = MainController.insatnce;

  final List<Widget> pages = [
    const Home(),
    const Center(
      child: Text("Search", style: TextStyle(color: SpColor.offWhite)),
    ),
    const Center(
      child: Text("Profile", style: TextStyle(color: SpColor.offWhite)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. الـ AppBar: عرض هوية المستخدم والتنبيهات
      appBar: const SPAppbar(),

      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      // 6. الزر العائم (إضافة مصروف يدوياً)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.DASHBOARD);
        },
        backgroundColor: SpColor.accentBlue.withValues(alpha: 0.84),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 7. شريط التنقل السفلي (Bottom Navigation Bar)
      bottomNavigationBar: const SPBottomNavBar(),
    );
  }
}
