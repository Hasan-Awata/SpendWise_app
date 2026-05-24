import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class UpdateWalletController extends GetxController {
  UpdateWalletController({
    required this.updateWalletUseCase,
    required this.walletsListController,
  });

  final UpdateWalletUseCase updateWalletUseCase;
  final WalletsListController walletsListController;

  final isLoading = false.obs;

  Future<void> updateWallet(WalletEntity wallet) async {
    try {
      isLoading.value = true;

      // حفظ النسخة القديمة للـ rollback
      final old = walletsListController.wallets.firstWhereOrNull(
        (e) => e.localId == wallet.localId,
      );

      // =========================
      // OPTIMISTIC UPDATE
      // =========================
      walletsListController.updateWalletLocally(wallet);

      final result = await updateWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          // rollback
          if (old != null) {
            walletsListController.updateWalletLocally(old);
          }

          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (_) {
          HelperFunction.showSnackBar("نجاح", "تم التحديث");
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
}
