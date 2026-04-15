// // تعليق: حذف محفظة — منفصل عن الجلب والإضافة
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class DeleteWalletController extends GetxController {
  DeleteWalletController({required this.deleteWalletUseCase});

  final DeleteWalletUseCase deleteWalletUseCase;

  final isDeleting = false.obs;

  Future<void> deleteWallet(int walletId) async {
    isDeleting.value = true;
    final result = await deleteWalletUseCase.call(walletId);

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "خطأ في الحذف",
          failure.message,
          isError: true,
        );
        if (Get.isRegistered<WalletsListController>()) {
          Get.find<WalletsListController>().loadWallets();
        }
      },
      (_) {
        if (Get.isRegistered<WalletsListController>()) {
          final list = Get.find<WalletsListController>();
          list.wallets.removeWhere((w) => w.walletId == walletId);
        }
        HelperFunction.showSnackBar("نجاح", "تم حذف المحفظة بنجاح");
      },
    );
    isDeleting.value = false;
  }
}
