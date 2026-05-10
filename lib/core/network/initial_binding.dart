import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/auth/presentation/bindings/auth_binding.dart';
import 'package:spendwise/features/expense/presentation/bindings/expense_binding.dart';
import 'package:spendwise/features/home/presentation/bindings/main_binding.dart'
    show MainBinding;
import 'package:spendwise/features/income/presentation/bindings/income_binding.dart';
import 'package:spendwise/features/savings_goals/presentation/bindings/saving_goal_binding.dart';
import 'package:spendwise/features/tags/presentation/bindings/tag_binding.dart';
import 'package:spendwise/features/wallet/presentation/bindings/wallet_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Isar, permanent: true);
    AuthBinding(permanentAuthController: true).dependencies();

    WalletBinding().dependencies();
    MainBinding().dependencies();
    TagBinding().dependencies();
    IncomeBinding().dependencies();
    SavingGoalBinding().dependencies();
    ExpenseBinding().dependencies();
  }
}
