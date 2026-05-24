import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/presentation/main_screen/home.dart';
import 'package:spendwise/presentation/main_screen/main_controller.dart';
import 'package:spendwise/presentation/widgets/new/appbar.dart';
import 'package:spendwise/presentation/widgets/new/bottom_nav_bar.dart';
import 'package:spendwise/utils/colors.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainController controller = MainController.insatnce;
  int currentIndex = 0;

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
      backgroundColor: SpColor.primaryDark, // خلفية فاتحة ومريحة للعين
      // 1. الـ AppBar: عرض هوية المستخدم والتنبيهات
      appBar: SPAppbar(),

      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      // 6. الزر العائم (إضافة مصروف يدوياً)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: SpColor.accentBlue.withValues(alpha: 0.84),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 7. شريط التنقل السفلي (Bottom Navigation Bar)
      bottomNavigationBar: SPBottomNavBar(),
    );
  }
}
