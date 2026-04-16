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

  // // تعليق: تنفيذ عملية الحذف مع تحديث قائمة المحافظ العامة بناءً على المعرف المحلي
  Future<void> deleteWallet(WalletModel wallet) async {
    try {
      isDeleting.value = true;

      // تنفيذ الحذف عبر الـ Usecase (التي ستسم المحفظة بـ REMOVE في المستودع)
      final result = await deleteWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "خطأ في الحذف",
            failure.message,
            isError: true,
          );
          // في حال فشل الحذف لسبب تقني، نعيد تحميل القائمة للتأكد من حالة البيانات
          if (Get.isRegistered<WalletsListController>()) {
            Get.find<WalletsListController>().loadWallets();
          }
        },
        (_) {
          // // تعليق: تحديث سريع لواجهة المستخدم بحذف المحفظة من القائمة النشطة
          if (Get.isRegistered<WalletsListController>()) {
            final listController = Get.find<WalletsListController>();

            // إصلاح: الحذف بناءً على localId لضمان عمله حتى لو كانت المحفظة غير مزامنة بعد
            listController.wallets.removeWhere(
              (w) => w.localId == wallet.localId,
            );
          }
          HelperFunction.showSnackBar("نجاح", "تم حذف المحفظة بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "حدث خطأ غير متوقع", isError: true);
    } finally {
      isDeleting.value = false;
    }
  }
}
