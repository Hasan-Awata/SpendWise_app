import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          const SizedBox(height: 40),
          // 1. قسم معلومات المستخدم
          _buildHeader(),
          const SizedBox(height: 30),

          // 2. قسم الإعدادات (مثال: تغيير العملة، الوضع الداكن)
          _buildSectionTitle("الإعدادات"),
          _buildOptionTile(Icons.currency_exchange, "العملة المفضلة", () {}),
          _buildOptionTile(Icons.notifications_outlined, "التنبيهات", () {}),

          // 3. قسم الدعم
          _buildSectionTitle("حول التطبيق"),
          _buildOptionTile(Icons.info_outline, "عن التطبيق", () {}),
          _buildOptionTile(Icons.support_agent, "تواصل معنا", () {}),

          const SizedBox(height: 30),

          // 4. تسجيل الخروج
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
    children: [
      const CircleAvatar(
        radius: 45,
        backgroundColor: SpColor.accentBlue,
        child: Icon(Icons.person, size: 50, color: Colors.white),
      ),
      const SizedBox(height: 15),
      const Text(
        "مستخدم SpendWise",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        CurrentUser.user!.userName!,
        style: TextStyle(color: Colors.white60),
      ),
    ],
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: SpColor.accentBlue,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.white30,
          ),
          onTap: onTap,
        ),
      );

  Widget _buildLogoutButton() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
    ),
    child: ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text(
        'تسجيل الخروج',
        style: TextStyle(color: Colors.redAccent, fontSize: 16),
      ),
      onTap: () {
        Get.defaultDialog(
          title: "تسجيل الخروج",
          middleText: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
          backgroundColor: const Color(0xFF162030),
          titleStyle: const TextStyle(color: Colors.white),
          middleTextStyle: const TextStyle(color: Colors.white70),
          textConfirm: "نعم",
          textCancel: "إلغاء",
          buttonColor: Colors.redAccent,
          onConfirm: () async {
            Get.back();
            controller.currentIndex.value = 0;
            await logoutController.logOut();
          },
        );
      },
    ),
  );
}
