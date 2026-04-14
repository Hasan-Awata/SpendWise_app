// // تعليق: المتحكم الخاص بالمحفظة لإدارة الحالة والعمليات مع معالجة نتائج Dartz (Fold)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/delete_wallet_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/get_wallets_usecase.dart';
import 'package:spendwise/features/wallet/domain/usecases/update_wallet_usecase.dart';

class WalletController extends GetxController {
  final GetMyWalletsUseCase getMyWalletsUseCase;
  final AddWalletUseCase addWalletUseCase;
  final UpdateWalletUseCase updateWalletUseCase;
  final DeleteWalletUseCase deleteWalletUseCase;

  WalletController({
    required this.getMyWalletsUseCase,
    required this.addWalletUseCase,
    required this.updateWalletUseCase,
    required this.deleteWalletUseCase,
  });

  // // تعليق: متغيرات الحالة المراقبة باستخدام Rx
  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;
  var selectedCurrencyId = 144.obs;

  // // تعليق: متحكمات الحقول النصية والقوائم
  TextEditingController balanceController = TextEditingController();
  TextEditingController currencySearchController = TextEditingController();
  var filteredCurrencies = <String>[].obs;
  final List<String> allCurrencyNames = CurrencyLocal().allCurrencies
      .map((c) => c.currencyName)
      .toList();

  @override
  void onInit() {
    super.onInit();
    filteredCurrencies.assignAll(allCurrencyNames);
    // loadWallets();
  }

  // // تعليق: دالة البحث عن العملات وتحديث القائمة المراقبة
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

  // // تعليق: جلب المحافظ ومعالجة حالات Either (Left=Failure, Right=Data)
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

  // // تعليق: إضافة محفظة جديدة ومعالجة نتيجة العملية
  Future<void> addNewWallet() async {
    if (balanceController.text.isEmpty || !balanceController.text.isNum) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى إدخال مبلغ صحيح",
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    try {
      final currency = await CurrencyLocal().getCurrency(
        currencySearchController.text,
      );
      final userId = await GetUserIdUsecase.userId;

      final newWallet = WalletModel(
        userId: 12,
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
        (unit) {
          loadWallets(); // إعادة تحميل القائمة للتزامن
          HelperFunction.showSnackBar("نجاح", "تمت إضافة المحفظة بنجاح");
          balanceController.clear();
          currencySearchController.clear();
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteWallet(int walletId) async {
    isLoading.value = true;
    final result = await deleteWalletUseCase.call(walletId);

    result.fold(
      (failure) {
        HelperFunction.showSnackBar(
          "خطأ في الحذف",
          failure.message,
          isError: true,
        );
      },
      (unit) {
        wallets.removeWhere((w) => w.walletId == walletId);
        HelperFunction.showSnackBar("نجاح", "تم حذف المحفظة بنجاح");
      },
    );
    isLoading.value = false;
  }
}
