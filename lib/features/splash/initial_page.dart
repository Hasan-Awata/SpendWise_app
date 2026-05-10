import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/routes/app_pages.dart';
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
  bool isWaiting = true;
  @override
  void initState() {
    super.initState();

    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Get.put<NetworkService>(NetworkService(), permanent: true);

    Get.put(Isar, permanent: true);
    await CurrentUser.initializeUser();
    await CurrencyLocal(Get.find<Isar>()).initializaCurrencies();

    final isLogged = CurrentUser.isUserLoggedIn;

    if (isLogged) {
      setState(() {
        isWaiting = true;
      });

      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return;

      Get.offAllNamed(Routes.MAIN_SCREEN);
    } else {
      await _initializeDataSources();

      if (!mounted) return;

      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!isWaiting)
        ? Introduction()
        : Container(
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

  Future<void> _initializeDataSources() async {
    await CurrencyLocal(Get.find<Isar>()).initializaCurrencies();
  }
}
