import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive/hive.dart';
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

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

Future<void> _clearAllData() async {
  // قائمة بالأسماء التي تريد حذفها
  List<String> boxesToClear = [
    "CURRENTUSER",
    "MYINCOME",
    "MYEXPENSE",
    "TAG_BOX",
    "WALLET",
  ];

  for (String boxName in boxesToClear) {
    // نفتح الـ Box ثم نمسح محتوياته، هذه الطريقة تعمل 100%
    var box = await Hive.openBox(boxName);
    await box.clear();
    // اختياري: إذا أردت حذف الملف نهائياً بعد التصفير
    // await box.deleteFromDisk();
  }
  print("✅ All local storage cleared successfully");
}

// دالة منظمة لتسجيل المحولات
void _registerHiveAdapters() {
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(ExpenseAdapter());
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
