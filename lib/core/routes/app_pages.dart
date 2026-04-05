import 'package:get/get.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/splash/introduction.dart';
import '../../features/income/presentation/pages/income_list_view.dart';
import '../../features/income/presentation/pages/add_income_view.dart';
import '../../features/income/presentation/bindings/income_binding.dart';

// // Logic: Defining routes as constants to avoid typos
abstract class Routes {
  static const INITIAL = '/introduction';
  static const SIGNUP = '/signup';
  static const LOGIN = '/login';
  static const INCOME_LIST = '/income-list';
  static const ADD_INCOME = '/add-income';
  static const MAIN_SCREEN = '/main-screen';
}

class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => const Introduction()),

    // Auth Routes
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignUpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LogInPage(),
      binding: AuthBinding(),
    ),

    // Protected Routes ( تحتاج لاحقاً لـ Middleware )
    GetPage(
      name: Routes.INCOME_LIST,
      page: () => const IncomeListView(),
      binding: IncomeBinding(),
      // middlewares: [AuthGuard()], // // سنضيف هذا لاحقاً لحماية الصفحة
    ),
    GetPage(
      name: Routes.ADD_INCOME,
      page: () => AddIncomeView(),
      binding: IncomeBinding(),
    ),
    GetPage(name: Routes.MAIN_SCREEN, page: () => MainScreen()),
  ];
}
