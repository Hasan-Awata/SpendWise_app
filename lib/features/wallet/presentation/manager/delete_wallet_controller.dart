import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class DeleteWalletController extends GetxController {
  DeleteWalletController({
    required this.deleteWalletUseCase,
    required this.walletsListController,
  });

  final DeleteWalletUseCase deleteWalletUseCase;

  final WalletsListController walletsListController;

  // =========================
  // STATE
  // =========================

  final isLoadingDelete = false.obs;

  // =========================
  // DELETE
  // =========================

  Future<void> deleteWallet(WalletEntity wallet) async {
    try {
      isLoadingDelete.value = true;

      // =====================
      // RELATION CHECK
      // =====================

      final incomes = Get.find<IncomesListController>();

      final isRelated = incomes.incomesList.any((income) {
        final incomeWalletId = income.walletId;

        final incomeLocalWalletId = income.wallet?.localId;

        return incomeWalletId == wallet.walletId ||
            incomeLocalWalletId == wallet.localId;
      });

      if (isRelated) {
        Get.back();

        HelperFunction.showSnackBar(
          "خطأ",
          "لا يمكن حذف المحفظة لأنها مرتبطة بدخل أو مصروف",
          isError: true,
        );

        return;
      }

      // =====================
      // CLOSE DIALOG
      // =====================

      Get.back();

      // =====================
      // OPTIMISTIC DELETE
      // =====================

      walletsListController.deleteWalletLocally(wallet.localId);

      // =====================
      // DELETE FROM SERVER/DB
      // =====================

      final result = await deleteWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          _handleError("فشل الحذف", failure.message);
        },
        (_) {
          HelperFunction.showSnackBar("تم بنجاح", "تم حذف المحفظة بنجاح");
          walletsListController.loadWallets(isRefresh: true);
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingDelete.value = false;
    }
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
