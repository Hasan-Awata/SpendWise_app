import 'package:get/get.dart';
import 'package:spendwise/core/network/initial_binding.dart';
// استيراد الـ Bindings
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/expense/presentation/bindings/expense_binding.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';

// استيراد الصفحات (Pages)
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
import 'package:spendwise/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spendwise/features/expense/presentation/pages/add_expense_view.dart';
import 'package:spendwise/features/expense/presentation/pages/expense_list_view.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
import 'package:spendwise/features/splash/initial_page.dart';
import 'package:spendwise/features/tags/presentation/pages/add_tag_page.dart';
import 'package:spendwise/features/tags/presentation/pages/tags_view.dart';
import 'package:spendwise/features/wallet/presentation/pages/add_wallet_view.dart';
import 'package:spendwise/features/wallet/presentation/pages/wallet_view.dart';
import '../../features/income/presentation/pages/income_list_view.dart';
import '../../features/income/presentation/pages/add_income_view.dart';

// This class defines constant route names to maintain a single source of truth and prevent typos
abstract class Routes {
  static const INITIAL = '/introduction';
  static const SIGNUP = '/signup';
  static const LOGIN = '/login';
  static const MAIN_SCREEN = '/main-screen';
  static const DASHBOARD = '/dashboard';

  // Wallet Routes
  static const LIST_WALLET = '/list-wallet';
  static const ADD_WALLET = '/add-wallet';

  // Tag Routes
  static const LIST_TAG = '/list-tag';
  static const ADD_TAG = '/add-tag';

  // Expense Routes
  static const LIST_EXPENSE = '/list-expense';
  static const ADD_EXPENSE = '/add-expense';

  // Income Routes
  static const LIST_INCOME = '/list-income';
  static const ADD_INCOME = '/add-income';
}

// AppPages manages the mapping between route names and their corresponding pages and bindings
class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    // --- Auth Module ---
    GetPage(
      name: Routes.INITIAL,
      page: () => InitialPage(),
      binding: AuthBinding(),
    ),
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

    // --- Core Module (Main Screens) ---
    GetPage(
      name: Routes.MAIN_SCREEN,
      page: () => const MainScreen(),
      // The MainScreen often acts as a hub, so we inject essential bindings here
      bindings: [
        WalletBinding(),
        TagBinding(),
        IncomeBinding(),
        ExpenseBinding(),
      ],
    ),
    GetPage(name: Routes.DASHBOARD, page: () => const DashboardPage()),

    // --- Wallet Module ---
    GetPage(
      name: Routes.LIST_WALLET,
      page: () => const WalletsView(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.ADD_WALLET,
      page: () => const AddWalletView(),
      binding: WalletBinding(),
    ),

    // --- Tag Module ---
    GetPage(
      name: Routes.LIST_TAG,
      page: () => TagsView(),
      binding: TagBinding(),
    ),
    GetPage(
      name: Routes.ADD_TAG,
      page: () => AddtagPage(),
      binding: TagBinding(),
    ),

    // --- Expense Module ---
    GetPage(
      name: Routes.LIST_EXPENSE,
      page: () => ExpenseListView(),
      bindings: [ExpenseBinding(), WalletBinding(), TagBinding()],
    ),
    GetPage(
      name: Routes.ADD_EXPENSE,
      page: () => AddExpenseView(),
      bindings: [ExpenseBinding(), WalletBinding(), TagBinding()],
    ),

    // --- Income Module ---
    GetPage(
      name: Routes.LIST_INCOME,
      page: () => const IncomeListView(),
      bindings: [IncomeBinding(), WalletBinding(), TagBinding()],
    ),
    GetPage(
      name: Routes.ADD_INCOME,
      page: () => AddIncomeView(),
      bindings: [IncomeBinding(), WalletBinding(), TagBinding()],
    ),
  ];
}
