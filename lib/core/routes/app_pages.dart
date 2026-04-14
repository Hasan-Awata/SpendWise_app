import 'package:get/get.dart';

import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spendwise/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/splash/initial_page.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/tags/presentation/pages/add_tag_page.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';
import 'package:spendwise/features/wallet/presentation/pages/add_wallet_view.dart';
import 'package:spendwise/features/wallet/presentation/pages/wallet_view.dart';
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
  static const ADD_TAG = '/add-tag';
  static const HOME = '/home';
  static const ADDWALLET = '/add-wallet';
  static const LISTWALLET = '/list-wallet';
  static const DASHBOARD = '/dashboard';
}

class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => InitialPage()),
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
    GetPage(name: Routes.DASHBOARD, page: () => const DashboardPage()),
    GetPage(
      name: Routes.INCOME_LIST,
      page: () => const IncomeListView(),
      bindings: [WalletBinding(), TagBinding(), IncomeBinding()],
    ),
    GetPage(
      name: Routes.ADD_INCOME,
      page: () => AddIncomeView(),
      bindings: [WalletBinding(), TagBinding(), IncomeBinding()],
    ),
    GetPage(
      name: Routes.MAIN_SCREEN,
      page: () => const MainScreen(),
      bindings: [IncomeBinding(), WalletBinding(), TagBinding()],
    ),
    GetPage(
      name: Routes.ADD_TAG,
      page: () => AddtagPage(),
      binding: TagBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainScreen(),
      bindings: [IncomeBinding(), WalletBinding(), TagBinding()],
    ),
    GetPage(name: Routes.ADDWALLET, page: () => const AddWalletView()),
    GetPage(name: Routes.LISTWALLET, page: () => const WalletsView()),
  ];
}
