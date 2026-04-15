// // تعليق: تعديل محفظة — جاهز لشاشة التعديل لاحقاً
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class UpdateWalletController extends GetxController {
  UpdateWalletController({required this.updateWalletUseCase});

  final UpdateWalletUseCase updateWalletUseCase;

  final isUpdating = false.obs;

  Future<void> updateWallet(int walletId, WalletModel wallet) async {
    isUpdating.value = true;
    final result = await updateWalletUseCase.call(walletId, wallet);

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "فشل التعديل",
          failure.message,
          isError: true,
        );
      },
      (_) {
        if (Get.isRegistered<WalletsListController>()) {
          Get.find<WalletsListController>().loadWallets();
        }
        HelperFunction.showSnackBar("نجاح", "تم تحديث المحفظة");
      },
    );
    isUpdating.value = false;
  }
}
