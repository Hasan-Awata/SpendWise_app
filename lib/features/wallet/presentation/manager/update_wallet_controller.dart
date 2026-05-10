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

  // =========================
  // STATE
  // =========================

  final isLoadingUpdate = false.obs;

  // =========================
  // UPDATE
  // =========================

  Future<void> updateWallet(WalletEntity wallet) async {
    try {
      isLoadingUpdate.value = true;

      // =====================
      // OPTIMISTIC UI
      // =====================

      walletsListController.updateWalletLocally(wallet);

      // =====================
      // UPDATE DATABASE/API
      // =====================

      final result = await updateWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          _handleError("فشل التحديث", failure.message);
        },
        (_) {
          Get.back();

          HelperFunction.showSnackBar("تم بنجاح", "تم تحديث المحفظة بنجاح");
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingUpdate.value = false;
    }
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
