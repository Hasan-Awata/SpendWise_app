import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spendwise/core/network/initial_binding.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/shared_service.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_adapter.dart';
import 'package:spendwise/features/expense/data/datasources/expense_local_datasource_impl.dart';
import 'package:spendwise/features/expense/data/models/expense_adapter.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/models/income_adapter.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/models/tag_adapter.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/models/wallet_adapter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تأكد من تهيئة التواريخ
  await initializeDateFormatting('ar', null);

  // 1. استخدام initFlutter بدلاً من init اليدوي لضمان استقرار المسارات
  await Hive.initFlutter();

  // تسجيل الـ Adapters
  _registerHiveAdapters();

  // 2. تهيئة الداتا سورس (تأكد أن هذه الدوال تفتح الـ Boxes إذا كانت مغلقة)
  await _initializeDataSources();

  // 3. تهيئة الخدمات الأساسية
  // ملاحظة: SharedPreferences.getInstance() داخلياً سيعود للعمل فوراً عند إعادة التشغيل
  await Get.putAsync(() => SharedPreferencesService().init(), permanent: true);

  CurrentUser.initializeUser();

  runApp(
  
    DevicePreview(enabled: false, builder: (context) => const MyApp()),
   
  );
}

// دالة منظمة لتسجيل المحولات
void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TagAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(WalletAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(IncomeAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CurrencyAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ExpenseAdapter());
}

// دالة منظمة لتهيئة الداتا سورس
Future<void> _initializeDataSources() async {
  await AppUserLocalDatasourceImpl().init();
  await TagLocalDatasourceImpl().init();
  await WalletLocalDatasourceImpl().init();
  await IncomeLocalDataSourceImpl().init();
  await ExpenseLocalDataSourceImpl().init();
  await CurrencyLocal().initializaCurrencies();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // الإنجليزية
        Locale('ar', 'SA'),
      ],
      textDirection: TextDirection.ltr,

      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      defaultTransition: Transition.cupertino,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
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
