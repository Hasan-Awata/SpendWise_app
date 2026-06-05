import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';
import 'package:spendwise/features/transaction/domain/usecases/get_transactions_usecase.dart'; // تأكد من استيراد الـ UseCase
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class DeleteWalletController extends GetxController {
  DeleteWalletController({
    required this.deleteWalletUseCase,
    required this.walletsListController,
    required this.getTransactionsUseCase, // أضفنا هذا
    required this.userIdUsecase, // نحتاج الـ userId
  });

  final DeleteWalletUseCase deleteWalletUseCase;
  final WalletsListController walletsListController;
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetUserIdUsecase userIdUsecase;

  final isLoading = false.obs;
  Future<void> deleteWallet(WalletEntity wallet) async {
    try {
      isLoading.value = true;

      // =========================
      // 1. منع الحذف إذا فيه معاملات
      // =========================
      if ((wallet.numberOfTransactions) > 0) {
        HelperFunction.showSnackBar(
          "لا يمكن الحذف",
          "هذه المحفظة تحتوي على معاملات مسجلة.",
          isError: true,
        );
        return;
      }

      // =========================
      // 2. جلب البيانات المحلية
      // =========================

      final userIdResult = await userIdUsecase.getUserId();
      int? userId;

      userIdResult.fold((failure) => userId = null, (id) => userId = id);

      if (userId == null) {
        HelperFunction.showSnackBar("خطأ", "فشل تحديد المستخدم", isError: true);
        return;
      }

      final expenses = Get.find<ExpensesListController>().expensesList;
      final incomes = Get.find<IncomesListController>().incomesList;
      final goals = Get.find<SavingGoalListController>().savingGoals;

      // =========================
      // 3. فحص currencyId
      // =========================

      final hasConflict =
          expenses.any((e) => e.currencyId! == wallet.currencyId) ||
          incomes.any((i) => i.walletId! == wallet.walletId) ||
          goals.any((g) => g.currencyId == wallet.currencyId);

      if (hasConflict) {
        HelperFunction.showSnackBar(
          "لا يمكن الحذف",
          "هناك بيانات مالية مرتبطة بنفس عملة المحفظة.",
          isError: true,
        );
        return;
      }

      // =========================
      // 4. حذف آمن
      // =========================

      final backup = wallet;
      walletsListController.deleteWalletLocally(wallet.localId);

      final result = await deleteWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          walletsListController.addWalletLocally(backup);

          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (message) {
          HelperFunction.showSnackBar("نجاح", "تم حذف المحفظة بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar(
        "خطأ",
        "حدث خطأ غير متوقع أثناء الحذف",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
