import 'package:get/get.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart'
    show ExpensesListController;
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';
import 'package:spendwise/features/transaction/presentation/manager/transaction_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class MainController extends GetxController {
  static MainController get instance => Get.find<MainController>();

  final Rxn<WalletEntity> selectWallet = Rxn<WalletEntity>();
  final RxBool showAll = false.obs;
  final RxInt currentIndex = 0.obs;

  // نستخدم هذه الحالة (isLoading) لربطها بالـ Shimmer في الواجهة
  final RxBool isLoading = false.obs;

  // تعريف الخدمات (Dependencies) مع مراعاة الحالة الآمنة
  ExpensesListController get expensesController =>
      Get.find<ExpensesListController>();
  IncomesListController get incomesListController =>
      Get.find<IncomesListController>();
  WalletsListController get walletListController =>
      Get.find<WalletsListController>();
  SavingGoalListController get savingGoalsController =>
      Get.find<SavingGoalListController>();
  TransactionController get transactionController =>
      Get.find<TransactionController>();

  @override
  void onInit() {
    super.onInit();
    // مراقبة تغيير المحفظة لتحديث البيانات فوراً
    ever(selectWallet, (WalletEntity? wallet) {
      if (wallet != null) {
        _triggerTotalsUpdate();
      }
    });
  }

  /// دالة لحساب إجمالي الدخل للمحفظة النشطة
  double getFilteredIncomeTotal(WalletEntity? activeWallet) {
    if (activeWallet == null) return 0.0;

    final dashboardDate = incomesListController.dashboardMonth.value;
    final activeCurrencyCode = (activeWallet.currency.code ?? "")
        .trim()
        .toUpperCase();
    final activeWalletIdStr = activeWallet.walletId?.toString() ?? "";

    return incomesListController.incomesList
        .where((i) {
          final isSameMonth =
              i.date.year == dashboardDate.year &&
              i.date.month == dashboardDate.month;
          final isSameWalletId =
              (i.walletId?.toString() == activeWalletIdStr) ||
              (i.wallet?.walletId?.toString() == activeWalletIdStr);
          final isSameCurrency =
              (i.wallet?.currency.code ?? "").trim().toUpperCase() ==
              activeCurrencyCode;

          return isSameMonth && (isSameWalletId || isSameCurrency);
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// دالة لحساب إجمالي المصاريف للمحفظة النشطة
  double getFilteredExpenseTotal(WalletEntity? activeWallet) {
    if (activeWallet == null) return 0.0;

    final dashboardDate = incomesListController.dashboardMonth.value;
    final activeCurrencyCode = (activeWallet.currency.code ?? "")
        .trim()
        .toUpperCase();
    final activeWalletIdStr = activeWallet.walletId?.toString() ?? "";

    return expensesController.expensesList
        .where((e) {
          if (e.isDeleted == true) return false;

          final isSameMonth =
              e.date.year == dashboardDate.year &&
              e.date.month == dashboardDate.month;
          final isSameWalletId =
              (e.walletId?.toString() == activeWalletIdStr) ||
              (e.wallet?.walletId?.toString() == activeWalletIdStr);
          final isSameCurrency =
              (e.wallet?.currency.code ?? "").trim().toUpperCase() ==
              activeCurrencyCode;

          return isSameMonth && (isSameWalletId || isSameCurrency);
        })
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void _triggerTotalsUpdate() {
    // التأكد من تسجيل الكنترولرات قبل الاستدعاء لتجنب الخطأ
    if (Get.isRegistered<ExpensesListController>()) {
      expensesController.updateDashboardTotals();
    }
    if (Get.isRegistered<IncomesListController>()) {
      incomesListController.updateDashboardTotals();
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// تحديث كافة البيانات من السيرفر مع إدارة حالة الـ Loading
  Future<void> refreshAllData() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      await Future.wait([
        walletListController.loadWallets(isRefresh: true),
        incomesListController.fetchAllIncomes(isRefresh: true),
        expensesController.fetchExpenses(isRefresh: true),
        savingGoalsController.loadSavingGoals(isRefresh: true),
      ]);
    } catch (e) {
      print("Error during refresh: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
