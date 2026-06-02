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

      // =========================
      // REGISTER ISAR
      // =========================
      if (!Get.isRegistered<Isar>()) {
        Get.put<Isar>(isar, permanent: true);
      }

      // =========================
      // INIT CURRENT USER
      // =========================
      await CurrentUser.initialize();

      // =========================
      // INIT CURRENCIES
      // =========================
      await CurrencyLocal(isar).initializaCurrencies();

      // =========================
      // CHECK LOGIN STATE
      // =========================
      final isLogged = CurrentUser.isLoggedIn;

      print("✅ User Logged In => $isLogged");

      // Splash delay
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // =========================
      // NAVIGATION
      // =========================
      if (isLogged) {
        await Get.offAllNamed(Routes.MAIN_SCREEN);
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

    return Scaffold(
      backgroundColor: SpColor.primaryDark,
      body: Center(
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
