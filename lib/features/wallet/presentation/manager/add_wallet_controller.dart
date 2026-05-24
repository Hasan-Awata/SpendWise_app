import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/domain/usecases/add_wallet_usecase.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:uuid/uuid.dart';

class AddWalletController extends GetxController {
  AddWalletController({
    required this.addWalletUseCase,
    required this.userIdUsecase,
    required this.walletsListController,
  });

  final AddWalletUseCase addWalletUseCase;

  final GetUserIdUsecase userIdUsecase;

  final WalletsListController walletsListController;

  // =========================
  // STATE
  // =========================

  final isLoadingSave = false.obs;

  final selectedCurrencyId = RxnInt();

  final selectedCurrency = Rxn<Currency>();

  // =========================
  // CONTROLLERS
  // =========================

  final balanceController = TextEditingController();

  final currencySearchController = TextEditingController();

  // =========================
  // CURRENCIES
  // =========================

  final RxList<String> filteredCurrencies = <String>[].obs;

  late final CurrencyLocal currencyLocal;

  late final List<Currency> allCurrencies;

  @override
  void onInit() {
    super.onInit();

    currencyLocal = CurrencyLocal(Get.find<Isar>());

    allCurrencies = currencyLocal.allCurrencies;

    _loadCurrencies();
  }

  // =========================
  // LOAD
  // =========================

  void _loadCurrencies() {
    filteredCurrencies.assignAll(
      allCurrencies.map((e) => e.currencyName ?? "Unknown").toList(),
    );
  }

  // =========================
  // SEARCH
  // =========================

  void searchCurrency(String query) {
    if (query.trim().isEmpty) {
      _loadCurrencies();

      return;
    }

    filteredCurrencies.assignAll(
      allCurrencies
          .where(
            (currency) => (currency.currencyName ?? "").toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .map((e) => e.currencyName ?? "Unknown")
          .toList(),
    );
  }

  // =========================
  // SELECT CURRENCY
  // =========================

  void selectCurrency(String value) {
    currencySearchController.text = value;

    final currency = allCurrencies.firstWhereOrNull(
      (e) => e.currencyName == value,
    );

    if (currency == null) {
      return;
    }

    selectedCurrency.value = currency;

    selectedCurrencyId.value = currency.id;
  }

  // =========================
  // SAVE
  // =========================

  Future<void> addNewWallet() async {
    if (!_validateInputs()) return;

    try {
      isLoadingSave.value = true;

      // =====================
      // USER ID
      // =====================

      int? userId;

      bool hasError = false;

      final userResult = await userIdUsecase.getUserId();

      userResult.fold(
        (failure) {
          hasError = true;

          _handleError("خطأ", failure.message);
        },
        (id) {
          userId = id;
        },
      );

      if (hasError || userId == null) {
        return;
      }

      // =====================
      // ENTITY
      // =====================

      final wallet = WalletEntity(
        localId: const Uuid().v4(),

        userId: userId!,

        currencyId: selectedCurrencyId.value!,

        currency: selectedCurrency.value!,

        balance: double.tryParse(balanceController.text.trim()) ?? 0,

        isSynced: false.obs,
      );

      // =====================
      // OPTIMISTIC UI
      // =====================

      walletsListController.addWalletLocally(wallet);

      // =====================
      // SAVE
      // =====================

      final result = await addWalletUseCase.call(wallet);

      result.fold(
        (failure) {
          _handleError("فشل الحفظ", failure.message);
        },
        (_) {
          HelperFunction.showSnackBar("تم بنجاح", "تم إنشاء المحفظة بنجاح");

          resetFields();
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  // =========================
  // VALIDATION
  // =========================

  bool _validateInputs() {
    // =====================
    // CURRENCY
    // =====================

    if (selectedCurrency.value == null || selectedCurrencyId.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار العملة");

      return false;
    }

    // =====================
    // DUPLICATE
    // =====================

    final isDuplicate = walletsListController.wallets.any(
      (wallet) =>
          wallet.currencyId == selectedCurrencyId.value && !wallet.isDeleted,
    );

    if (isDuplicate) {
      _handleError("تنبيه", "هذه المحفظة موجودة بالفعل");

      return false;
    }

    // =====================
    // BALANCE
    // =====================

    final balance = double.tryParse(balanceController.text.trim());

    if (balance == null || balance < 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال رصيد صحيح");

      return false;
    }

    return true;
  }

  // =========================
  // RESET
  // =========================

  void resetFields() {
    balanceController.clear();

    currencySearchController.clear();

    selectedCurrency.value = null;

    selectedCurrencyId.value = null;
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void onClose() {
    balanceController.dispose();

    currencySearchController.dispose();

    super.onClose();
  }
}
