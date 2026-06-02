import 'package:get/get.dart';
// ================= Core =================
import 'package:spendwise/core/network/initial_binding.dart';
import 'package:spendwise/core/utils/current_user.dart';
// ================= Auth =================
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/auth/presentation/pages/login_page.dart';
import 'package:spendwise/features/auth/presentation/pages/sign_up_page.dart';
// ================= Budget =================
import 'package:spendwise/features/budget/presentation/bindings/category_budget_binding.dart';
import 'package:spendwise/features/budget/presentation/pages/add_category_budget_page.dart';
import 'package:spendwise/features/budget/presentation/pages/category_budget_list_page.dart';
import 'package:spendwise/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spendwise/features/debts/presentation/pages/add_debt.dart';
import 'package:spendwise/features/debts/presentation/pages/show_debt.dart';
// ================= Expense =================
import 'package:spendwise/features/expense/presentation/bindings/expense_binding.dart';
import 'package:spendwise/features/expense/presentation/pages/add_expense_view.dart';
import 'package:spendwise/features/expense/presentation/pages/expense_list_view.dart';
// ================= Main =================
import 'package:spendwise/features/home/presentation/bindings/main_binding.dart';
import 'package:spendwise/features/home/presentation/pages/main_screen.dart';
// ================= Income =================
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/income/presentation/pages/add_income_view.dart';
import 'package:spendwise/features/income/presentation/pages/income_list_view.dart';
// ================= Goals =================
import 'package:spendwise/features/savings_goals/presentation/bindings/saving_goal_binding.dart';
import 'package:spendwise/features/savings_goals/presentation/pages/add_saving_goal_page.dart';
import 'package:spendwise/features/savings_goals/presentation/pages/saving_goals_list_page.dart';
import 'package:spendwise/features/splash/initial_page.dart';
// ================= Sync =================
import 'package:spendwise/features/sync/manager/sync_binding.dart';
// ================= Tags =================
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/tags/presentation/pages/add_tag_page.dart';
import 'package:spendwise/features/tags/presentation/pages/tags_view.dart';
import 'package:spendwise/features/transaction/presentation/binding/transaction_binding.dart';
// ================= Wallet =================
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';
import 'package:spendwise/features/wallet/presentation/pages/add_wallet_view.dart';
import 'package:spendwise/features/wallet/presentation/pages/wallet_view.dart';

abstract class Routes {
  static const INITIAL = '/introduction';
  static const SIGNUP = '/signup';
  static const LOGIN = '/login';

  static const MAIN_SCREEN = '/main-screen';
  static const DASHBOARD = '/dashboard';

  // Wallet
  static const LIST_WALLET = '/list-wallet';
  static const ADD_WALLET = '/add-wallet';

  // Tag
  static const LIST_TAG = '/list-tag';
  static const ADD_TAG = '/add-tag';

  // Expense
  static const LIST_EXPENSE = '/list-expense';
  static const ADD_EXPENSE = '/add-expense';

  // Income
  static const LIST_INCOME = '/list-income';
  static const ADD_INCOME = '/add-income';

  // Goals
  static const GOAL_LIST = "/goal-list";
  static const ADD_GOAL = "/add-goal";

  // Budget
  static const CATEGORY_BUDGET = '/category-budget';
  static const ADD_CATEGORY_BUDGET = '/add-category-budget';

  static const SHARED_DEBTS = "/shared-debts";
  static const ADD_SHARED_DEBTS = "/add-shared-debts";
}

class AppPages {
  static const INITIAL = Routes.INITIAL;

  static final routes = [
    // =====================================================
    // INITIAL
    // =====================================================
    GetPage(
      name: Routes.INITIAL,
      page: () => const InitialPage(),
      bindings: [AuthBinding(), SyncBinding(), InitialBinding()],
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

    // =====================================================
    // MAIN
    // =====================================================
    GetPage(
      name: Routes.MAIN_SCREEN,
      page: () => const MainScreen(),
      bindings: [
        MainBinding(),
        WalletBinding(),
        ExpenseBinding(),
        IncomeBinding(),
        TagBinding(),
        SavingGoalBinding(),
        TransactionBinding(),
        CategoryBudgetBinding(), // 🔥 مهم جداً هنا
      ],
    ),

    GetPage(name: Routes.DASHBOARD, page: () => const DashboardPage()),

    // =====================================================
    // WALLET
    // =====================================================
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

    // =====================================================
    // TAG
    // =====================================================
    GetPage(
      name: Routes.LIST_TAG,
      page: () => TagsView(),
      binding: TagBinding(),
    ),

    GetPage(
      name: Routes.ADD_TAG,
      page: () => AddTagPage(),
      binding: TagBinding(),
    ),

    // =====================================================
    // EXPENSE
    // =====================================================
    GetPage(
      name: Routes.LIST_EXPENSE,
      page: () => ExpenseListView(),
      binding: ExpenseBinding(),
    ),

    GetPage(
      name: Routes.ADD_EXPENSE,
      page: () => AddExpenseView(),
      bindings: [CategoryBudgetBinding(), ExpenseBinding()],
    ),

    // =====================================================
    // INCOME
    // =====================================================
    GetPage(
      name: Routes.LIST_INCOME,
      page: () => IncomeListView(),
      binding: IncomeBinding(),
    ),

    GetPage(
      name: Routes.ADD_INCOME,
      page: () => AddIncomeView(),
      binding: IncomeBinding(),
    ),

    // =====================================================
    // GOALS
    // =====================================================
    GetPage(
      name: Routes.GOAL_LIST,
      page: () => SavingGoalsListPage(),
      binding: SavingGoalBinding(),
    ),

    GetPage(
      name: Routes.ADD_GOAL,
      page: () => const AddSavingGoalPage(),
      binding: SavingGoalBinding(),
    ),

    // =====================================================
    // BUDGET (🔥 FIXED IMPORTANT PART)
    // =====================================================
    GetPage(
      name: Routes.CATEGORY_BUDGET,
      page: () => const CategoryBudgetListPage(),
      binding: CategoryBudgetBinding(),
    ),

    GetPage(
      name: Routes.ADD_CATEGORY_BUDGET,
      page: () => ManageCategoryBudgetScreen(userId: CurrentUser.userId!),
      binding:
          CategoryBudgetBinding(), // 🔥 نفس الـ binding لضمان shared controller
    ),
    GetPage(name: Routes.ADD_SHARED_DEBTS, page: () => AddSharedDebtView()),
    GetPage(name: Routes.SHARED_DEBTS, page: () => const SharedDebtsView()),
  ];
}
