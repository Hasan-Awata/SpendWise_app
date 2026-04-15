// // تعليق: جلب قائمة المحافظ فقط — الحذف والتعديل في متحكمات منفصلة
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletsListController extends GetxController {
  WalletsListController({required this.getMyWalletsUseCase});

  final GetMyWalletsUseCase getMyWalletsUseCase;

  final wallets = <WalletModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    final result = await getMyWalletsUseCase.call(
      PageRequest(pageNumber: 1, pageSize: 20),
    );

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "خطأ في الجلب",
          failure.message,
          isError: true,
        );
      },
      (pagedResponse) {
        wallets.assignAll(pagedResponse.data);
      },
    );
    isLoading.value = false;
  }
}
