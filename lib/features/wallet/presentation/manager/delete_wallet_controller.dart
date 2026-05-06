// // تعليق: متحكم حذف المحفظة المصلح - يعتمد على المعرف المحلي لضمان دقة الحذف في كافة حالات الشبكة
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class DeleteWalletController extends GetxController {
  final DeleteWalletUseCase deleteWalletUseCase;

  DeleteWalletController({required this.deleteWalletUseCase});

  final isDeleting = false.obs;

  Future<void> deleteWallet(WalletModel wallet) async {
    try {
      isDeleting.value = true;

      final result = await deleteWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "خطأ في الحذف",
            failure.message,
            isError: true,
          );
        },
        (_) {
          // // استخدام Get.find مباشرة لضمان تحديث القائمة فوراً
          if (Get.isRegistered<WalletsListController>()) {
            final listController = Get.find<WalletsListController>();

            // الحذف من القائمة المعروضة بناءً على localId
            listController.wallets.removeWhere(
              (w) => w.localId == wallet.localId,
            );
            listController.wallets.refresh();
          }

          if (Get.isOverlaysOpen) Get.back();

          // HelperFunction.showSnackBar("نجاح", "تم حذف المحفظة بنجاح");
        },
      );
    } catch (e) {
      print("Delete Controller Error: $e");
      HelperFunction.showSnackBar("خطأ", "حدث خطأ غير متوقع", isError: true);
    } finally {
      isDeleting.value = false;
    }
  }
}
