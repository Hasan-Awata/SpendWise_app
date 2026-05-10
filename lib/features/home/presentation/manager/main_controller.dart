import 'package:get/get.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart'
    show IncomesListController;
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class MainController extends GetxController {
  static MainController get instance => Get.find<MainController>();

  final Rxn<WalletEntity> selectWallet = Rxn<WalletEntity>();
  final RxBool showAll = false.obs;
  final RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    everAll([Get.find<WalletsListController>().wallets], (_) {
      refreshAllData();
    });
    refreshAllData();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  Future<void> refreshAllData() async {
    try {
      isLoading.value = true;

      await Future.wait([
        Get.find<WalletsListController>().loadWallets(isRefresh: true),
        Get.find<IncomesListController>().fetchAllIncomes(isRefresh: true),
        Get.find<ExpensesListController>().fetchExpenses(isRefresh: true),
        Get.find<SavingGoalListController>().loadSavingGoals(isRefresh: true),
      ]);
    } catch (e) {
      print("Error during refresh: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
