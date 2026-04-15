import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
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
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/models/income_adapter.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/models/tag_adapter.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/models/wallet_adapter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  final supportDir = await getApplicationSupportDirectory();
  final hiveDir = Directory('${supportDir.path}${Platform.pathSeparator}hive');
  if (!await hiveDir.exists()) {
    await hiveDir.create(recursive: true);
  }
  Hive.init(hiveDir.path);

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(CurrencyAdapter());

  await AppUserLocalDatasourceImpl().init();
  await TagLocalDatasourceImpl().init();
  await WalletLocalDatasourceImpl().init();
  await IncomeLocalDataSourceImpl().init();
  await CurrencyLocal().initializaCurrencies();
  await Get.putAsync(() => SharedPreferencesService().init(), permanent: true);
  CurrentUser.initializeUser();

  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
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
