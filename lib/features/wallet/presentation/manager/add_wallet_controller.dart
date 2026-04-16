// // تعليق: إضافة محفظة واختيار العملة — منفصل عن قائمة المحافظ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class AddWalletController extends GetxController {
  AddWalletController({required this.addWalletUseCase});

  final AddWalletUseCase addWalletUseCase;

  final isLoadingSave = false.obs;
  final selectedCurrencyId = 144.obs;

  final balanceController = TextEditingController();
  final currencySearchController = TextEditingController();
  final filteredCurrencies = <String>[].obs;

  final List<String> allCurrencyNames = CurrencyLocal().allCurrencies
      .map((c) => c.currencyName)
      .toList();

  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    print("userID is=> $userId");
    filteredCurrencies.assignAll(allCurrencyNames);
  }

  void searchCurrency(String query) {
    if (query.isEmpty) {
      filteredCurrencies.assignAll(allCurrencyNames);
    } else {
      filteredCurrencies.assignAll(
        allCurrencyNames
            .where((c) => c.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  Future<void> addNewWallet() async {
    if (balanceController.text.isEmpty || !balanceController.text.isNum) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى إدخال مبلغ صحيح",
        isError: true,
      );
      return;
    }

    isLoadingSave.value = true;
    try {
      final currency = await CurrencyLocal().getCurrency(
        currencySearchController.text,
      );

      print(currency.toString());
      if (userId == 0) {
        HelperFunction.showSnackBar(
          "تنبيه",
          "لا يوجد مستخدم مسجل. يرجى تسجيل الدخول مجدداً",
          isError: true,
        );
        return;
      }

      final newWallet = WalletModel(
        userId: userId,
        currency: currency,
        balance: double.parse(balanceController.text.trim()),
        isSaved: true,
      );

      final result = await addWalletUseCase.call(newWallet);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "فشل الإضافة",
            failure.message,
            isError: true,
          );
        },
        (_) {
          if (Get.isRegistered<WalletsListController>()) {
            Get.find<WalletsListController>().loadWallets();
          }
          HelperFunction.showSnackBar("نجاح", "تمت إضافة المحفظة بنجاح");
          balanceController.clear();
          currencySearchController.clear();
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", e.toString(), isError: true);
    } finally {
      isLoadingSave.value = false;
    }
  }

  @override
  void onClose() {
    balanceController.dispose();
    currencySearchController.dispose();
    super.onClose();
  }
}
