import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spendwise/core/network/initial_binding.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/services/init_isar.dart';
import 'package:spendwise/core/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  await InitIsar.init();

  // await SyncQueueRepositoryImpl(InitIsar.isar!).clearQueue();
  // InitIsar.clear();
  // Get.put<AppUserLocalDatasource>(
  //   AppUserLocalDatasourceImpl(Get.find<Isar>()),
  //   permanent: true,
  // );

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
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
