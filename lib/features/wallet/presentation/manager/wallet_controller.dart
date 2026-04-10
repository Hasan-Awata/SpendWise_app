import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletController extends GetxController {
  final GetWalletsUseCase getWalletsUseCase;
  final AddWalletUseCase addWalletUseCase;

  WalletController({
    required this.getWalletsUseCase,
    required this.addWalletUseCase,
  });

  // // تعليق: استخدام RxList لمراقبة التغييرات في قائمة المحافظ وتحديث الواجهة تلقائياً
  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;
  var wallet = Rxn<WalletModel>();

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    try {
      wallets.value = await getWalletsUseCase.call();
    } catch (e) {
      HelperFunction.showSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNewWallet() async {
    try {
      await addWalletUseCase.call(wallet.value!);
      await loadWallets();
      HelperFunction.showSnackBar("Success", "Adding Wallet");
    } catch (e) {
      HelperFunction.showSnackBar("Error", e.toString());
    }
  }
}
