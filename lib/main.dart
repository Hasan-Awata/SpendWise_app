import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:spendwise/core/network/initial_binding.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/auth/data/models/user_adapter.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasource.dart';
import 'package:spendwise/features/income/data/datasources/income_local_datasources_impl.dart';
import 'package:spendwise/features/income/data/models/income_adapter.dart';
import 'package:spendwise/features/splash/introduction.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource.dart';
import 'package:spendwise/features/tags/data/datasources/tag_local_datasource_impl.dart';
import 'package:spendwise/features/tags/data/models/tag_adapter.dart';
import 'package:spendwise/features/wallet/data/datasources/wallet_local_datasource_impl.dart';
import 'package:spendwise/features/wallet/data/models/wallet_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Hive.deleteBoxFromDisk('TAG');
  // Hive.deleteBoxFromDisk('MYINCOME');
  // Hive.deleteBoxFromDisk('WALLET');
  // Hive.deleteBoxFromDisk('CURRENTUSER');

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(IncomeAdapter());

  await AppUserLocalDatasourceImpl().init();
  await TagLocalDatasourceImpl().init();
  await WalletLocalDatasourceImpl().init();
  await IncomeLocalDataSourceImpl().init();

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: const Introduction(),
    );
  }
}
