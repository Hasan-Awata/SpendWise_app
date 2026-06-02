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

  // نوع المحفظة
  final isSaved = false.obs;

  // المحفظة المصدر
  final selectedSourceWallet = Rxn<WalletEntity>();

  // =========================
  // CONTROLLERS
  // =========================

  final balanceController = TextEditingController();

  final currencySearchController = TextEditingController();

  final sourceWalletSearchController = TextEditingController();

  // =========================
  // CURRENCIES
  // =========================

  final RxList<String> filteredCurrencies = <String>[].obs;

  late final CurrencyLocal currencyLocal;

  late final List<Currency> allCurrencies;

  // المحافظ العادية المتاحة لتكون مصدر
  List<WalletEntity> get availableSourceWallets =>
      walletsListController.regularWallets.where((w) => !w.isDeleted).toList();

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
  // TOGGLE TYPE
  // =========================

  void toggleIsSaved(bool value) {
    isSaved.value = value;

    selectedSourceWallet.value = null;

    sourceWalletSearchController.clear();

    // تنظيف العملة عند التبديل
    if (value) {
      selectedCurrency.value = null;

      selectedCurrencyId.value = null;

      currencySearchController.clear();
    }
  }

  // =========================
  // SELECT SOURCE WALLET
  // =========================

  void selectSourceWallet(String walletLabel) {
    sourceWalletSearchController.text = walletLabel;

    final wallet = availableSourceWallets.firstWhereOrNull(
      (w) =>
          "${w.currency.currencyName} (${w.balance.toStringAsFixed(2)})" ==
          walletLabel,
    );

    if (wallet == null) {
      return;
    }

    selectedSourceWallet.value = wallet;

    // وراثة العملة تلقائياً
    selectedCurrency.value = wallet.currency;

    selectedCurrencyId.value = wallet.currencyId;
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

        isSaved: isSaved.value,

        isSynced: false.obs,
      );

      // =====================
      // خصم الرصيد من المحفظة الأصلية
      // =====================

      if (isSaved.value && selectedSourceWallet.value != null) {
        walletsListController.decreaseWalletBalance(
          walletId: selectedSourceWallet.value!.walletId!,
          amount: wallet.balance,
        );
      }

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
          HelperFunction.showSnackBar(
            "تم بنجاح",
            isSaved.value
                ? "تم إنشاء المحفظة الادخارية بنجاح"
                : "تم إنشاء المحفظة بنجاح",
          );

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
    // SOURCE WALLET
    // =====================

    if (isSaved.value && selectedSourceWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار المحفظة المصدر");

      return false;
    }

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

    // المحافظ العادية
    final isDuplicateRegular = walletsListController.regularWallets.any(
      (wallet) =>
          wallet.currencyId == selectedCurrencyId.value && !wallet.isDeleted,
    );

    // المحافظ الادخارية
    final isDuplicateSavings = walletsListController.savingsWallets.any(
      (wallet) =>
          wallet.currencyId == selectedCurrencyId.value && !wallet.isDeleted,
    );

    // تحقق حسب النوع
    if (!isSaved.value && isDuplicateRegular) {
      _handleError("تنبيه", "توجد محفظة عادية بهذه العملة مسبقاً");

      return false;
    }

    if (isSaved.value && isDuplicateSavings) {
      _handleError("تنبيه", "توجد محفظة ادخارية بهذه العملة مسبقاً");

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

    // =====================
    // SOURCE BALANCE
    // =====================

    if (isSaved.value && balance > selectedSourceWallet.value!.balance) {
      _handleError("الرصيد غير كافٍ", "رصيد المحفظة المصدر لا يكفي");

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

    sourceWalletSearchController.clear();

    selectedCurrency.value = null;

    selectedCurrencyId.value = null;

    selectedSourceWallet.value = null;

    isSaved.value = false;
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

    sourceWalletSearchController.dispose();

    super.onClose();
  }
}
