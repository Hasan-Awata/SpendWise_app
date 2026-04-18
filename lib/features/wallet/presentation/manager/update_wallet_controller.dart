// // تعليق: تعديل محفظة — جاهز لشاشة التعديل لاحقاً
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

// // تعليق: متحكم التعديل - تم توحيد البارامترات لتسهيل الاستدعاء من واجهة المستخدم مباشرة
class UpdateWalletController extends GetxController {
  UpdateWalletController({required this.updateWalletUseCase});

  final UpdateWalletUseCase updateWalletUseCase;
  final isUpdating = false.obs;

  // // إصلاح: جعل الدالة تقبل الموديل مباشرة واستخراج المعرف داخلياً
  Future<void> updateWallet(WalletModel wallet) async {
    if (wallet.walletId == null) return;

    isUpdating.value = true;
    // نمرر الـ ID والموديل لـ Usecase بناءً على توقيعها
    final result = await updateWalletUseCase.call(
      wallet.walletId ?? -1,
      wallet,
    );

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "فشل التعديل",
          failure.message,
          isError: true,
        );
      },
      (_) {
        print("✅ Update Success in Data Layer");

        // // Logic: التحديث الفوري في الواجهة دون انتظار السيرفر
        if (Get.isRegistered<WalletsListController>()) {
          final listController = Get.find<WalletsListController>();

          // البحث عن مكان المحفظة في القائمة الحالية وتحديثها
          int index = listController.wallets.indexWhere(
            (w) =>
                (w.walletId != null && w.walletId == wallet.walletId) ||
                (w.localId == wallet.localId),
          );

          if (index != -1) {
            // استخدام refresh() أو استبدال العنصر لضمان تحديث RxList
            listController.wallets[index] = wallet;
            listController.wallets.refresh();
            listController.calculateTotals();
            print("📱 UI Updated Instantly at index: $index");
          }
        }
        HelperFunction.showSnackBar("نجاح", "تم تحديث المحفظة");
      },
    );
    isUpdating.value = false;
  }
}
