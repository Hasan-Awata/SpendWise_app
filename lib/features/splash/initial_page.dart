import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/splash/introduction.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';

class InitialPage extends StatefulWidget {
  InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isWaiting = true;
  @override
  void initState() {
    super.initState();

    Get.put(NetworkService(), permanent: true);
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    CurrentUser.initializeUser();
    final isLogged = CurrentUser.isUserLoggedIn;

    if (isLogged) {
      setState(() {
        isWaiting = true;
      });

      // إعطاء وقت كافٍ للمستخدم لرؤية شعار التطبيق وللنظام لإنهاء الحقن
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) {
        return;
      }
      Get.offAllNamed(Routes.MAIN_SCREEN);
    } else {
      _initializeDataSources();
      CurrentUser.initializeUser();
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
    await AppUserLocalDatasourceImpl().init();
    await TagLocalDatasourceImpl().init();
    await WalletLocalDatasourceImpl().init();
    await IncomeLocalDataSourceImpl().init();
    await ExpenseLocalDataSourceImpl().init();
    await CurrencyLocal().initializaCurrencies();
  }
}
