import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spendwise/core/network/initial_binding.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      UserModelSchema,
      TagModelSchema,
      WalletModelSchema,
      IncomeModelSchema,
      ExpenseModelSchema,
      SavingGoalModelSchema,
      CurrencySchema,
    ],
    directory: dir.path,
    inspector: true,
  );
  Get.put<Isar>(isar, permanent: true);
  Get.put<AppUserLocalDatasource>(
    AppUserLocalDatasourceImpl(Get.find<Isar>()),
    permanent: true,
  );

  // await isar.writeTxn(() async {
  //   await isar.clear();
  // });

  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      locale: const Locale('ar', 'SA'),
      textDirection: TextDirection.rtl,
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto',
        scaffoldBackgroundColor: SpColor.primaryDark,
        appBarTheme: AppBarTheme(
          backgroundColor: SpColor.primaryDark,
          foregroundColor: SpColor.accentBlue,
          elevation: 0,
          centerTitle: true,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: SpColor.accentBlue,
          selectionColor: SpColor.accentBlue.withOpacity(0.3),
          selectionHandleColor: SpColor.accentBlue,
        ),
      ),
    );
  }
}
