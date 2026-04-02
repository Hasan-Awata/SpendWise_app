import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/splash/introduction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(enabled: true, builder: (context) => const MyApp()),
  );
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

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Noto',

        scaffoldBackgroundColor: SpColor.primaryDark,
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
