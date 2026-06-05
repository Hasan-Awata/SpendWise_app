// // تعليق: الكود المحدث لشاشة MainScreen مع تصحيح أخطاء الـ Index ومعالجة تسجيل الخروج
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/presentation/manager/logout_controller.dart';
import 'package:spendwise/features/dashboard/presentation/budget_reports_view.dart';
import 'package:spendwise/features/dashboard/presentation/dashboard_view.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/home/presentation/pages/home.dart';
import 'package:spendwise/features/home/presentation/pages/profile.dart';
import 'package:spendwise/features/home/presentation/widgets/appbar.dart';
import 'package:spendwise/features/home/presentation/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // استخدام instance الموحد للمتحكم
  final MainController controller = MainController.instance;
  final LogoutController logoutController = Get.find<LogoutController>();

  // تعريف قائمة الصفحات - تأكد أنها تطابق عدد العناصر في SPBottomNavBar
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(), // Index 0
      BudgetReportsView(),
      DashboardView(),
      Profile(),
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
}
