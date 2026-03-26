import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:spendwise/presentation/auth/sign_up.dart';
import 'package:spendwise/presentation/main_screen/main_screen.dart';
import 'package:spendwise/presentation/splash/introduction.dart';
import 'package:spendwise/presentation/main_screen/main_screen.dart';
import 'package:spendwise/utils/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
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

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: SpColor.accentBlue,
          selectionColor: SpColor.accentBlue.withOpacity(0.3),
          selectionHandleColor: SpColor.accentBlue,
        ),
      ),
      home: Introduction(),
    );
  }
}
