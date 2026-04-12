import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/repositories/user_repository_impl.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';

class WalletController extends GetxController {
  final GetWalletsUseCase getWalletsUseCase;
  final AddWalletUseCase addWalletUseCase;
  var selectedCurrency = 144.obs;
  WalletController({
    required this.getWalletsUseCase,
    required this.addWalletUseCase,
  });

  // // تعليق: استخدام RxList لمراقبة التغييرات في قائمة المحافظ وتحديث الواجهة تلقائياً
  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;
  var wallet = Rxn<WalletModel>();
  TextEditingController balance = TextEditingController();
  TextEditingController currencySearchController = TextEditingController();

  late List<String> listNameCurrency =
      (CurrencyLocal().allCurrencies.map((c) => c.currencyName).toList()).obs;

  void searchCurrency(String textSearch) {
    listNameCurrency = listNameCurrency.where((name) {
      return name.toLowerCase().contains(textSearch);
    }).toList();
  }

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
      final currency = await CurrencyLocal().getCurrency(
        currencySearchController.text,
      );
      if (currency.currencyName != currencySearchController.text) {
        HelperFunction.showSnackBar(
          "Error",
          "Not currency in this name",
          isError: true,
        );
        return;
      }
      final userId = await GetUserIdUsecase.userId;
      wallet.value = WalletModel(
        userId: userId,
        currency: currency,
        balance: double.tryParse(balance.text.trim()) ?? 0.0,
      );

      await addWalletUseCase.call(wallet.value!);
      wallets.insert(0, wallet.value!);
      await loadWallets();
      HelperFunction.showSnackBar("Success", "Adding Wallet");
    } catch (e) {
      HelperFunction.showSnackBar("Error", e.toString());
    }
  }
}
