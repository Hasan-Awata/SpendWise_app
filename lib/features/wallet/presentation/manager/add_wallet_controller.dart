// // تعليق: إضافة محفظة واختيار العملة — منفصل عن قائمة المحافظ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/core/utils/current_user.dart';
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
  final selectedCurrencyId = 1.obs;

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
      print("Selected currency: ${currency.toString()}");
      bool isNotExist = !Get.find<WalletsListController>().wallets.any(
        (w) => w.currency.currencyName == currency.currencyName,
      );
      if (!isNotExist) {
        HelperFunction.showSnackBar(
          "تنبيه",
          "المحفظة موجودة مسبقا",
          isError: true,
        );
        return;
      }
      if (userId == 0) {
        HelperFunction.showSnackBar(
          "تنبيه",
          "لا يوجد مستخدم مسجل. يرجى تسجيل الدخول مجدداً",
          isError: true,
        );
        return;
      }

      if (userId == null) {
        CurrentUser.initializeUser();
      }
      final newWallet = WalletModel(
        userId: userId ?? CurrentUser.user!.userId,
        currency: currency,
        currencyId: currency.id,
        balance: double.parse(balanceController.text.trim()),
        isSaved: true,
      );

      final result = await addWalletUseCase.call(newWallet);

      result.fold(
        (failure) {
          if (failure is ServerFailure) {
            HelperFunction.showSnackBar(
              "فشل الإضافة",
              failure.message,
              isError: true,
            );
          }
        },
        (text) {
          print("📱 UI added Instantly ");
          HelperFunction.showSnackBar("نجاح", text ?? "تمت العملية بنجاح");
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
