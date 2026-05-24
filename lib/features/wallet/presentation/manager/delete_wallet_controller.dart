import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
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

  final isLoading = false.obs;

  Future<void> deleteWallet(WalletEntity wallet) async {
    try {
      isLoading.value = true;

      // حفظ النسخة للـ rollback
      final backup = wallet;

      // =========================
      // OPTIMISTIC DELETE
      // =========================
      walletsListController.deleteWalletLocally(wallet.localId);

      final result = await deleteWalletUseCase.call(wallet);

      result.fold((failure) {
        // rollback
        walletsListController.addWalletLocally(backup);

        HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
      }, (message) {});
    } finally {
      isLoading.value = false;
    }
  }
}
