import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/splash/introduction.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    try {
      final isar = InitIsar.isar;

      if (isar == null) {
        throw Exception("Isar initialization failed");
      }

      // تسجيل Isar داخل GetX
      if (!Get.isRegistered<Isar>()) {
        Get.put<Isar>(isar, permanent: true);
      }

      // تهيئة المستخدم الحالي
      await CurrentUser.initializeUser();

      // تهيئة العملات
      await CurrencyLocal(isar).initializaCurrencies();

      // التحقق من تسجيل الدخول
      final isLogged = CurrentUser.isUserLoggedIn;

      print("✅ User Logged In => $isLogged");

      // تأخير بسيط للسلاش
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      if (isLogged) {
        Get.offAllNamed(Routes.MAIN_SCREEN);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ InitialPage Error => $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Introduction();
    }

    return Container(
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
