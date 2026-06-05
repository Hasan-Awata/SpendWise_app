// add_income_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/update_wallet_controller.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class AddIncomeController extends GetxController {
  AddIncomeController({
    required this.addIncomeUseCase,
    required this.walletsListController,
    required this.tagController,
    required this.incomesListController,
    required this.tagActionController,
    required this.userIdUsecase,
    required this.updateWalletController,
  });

  final GetUserIdUsecase userIdUsecase;

  final AddIncomeUsecase addIncomeUseCase;

  final WalletsListController walletsListController;

  final TagViewController tagController;

  final TagActionController tagActionController;

  final IncomesListController incomesListController;

  final UpdateWalletController updateWalletController;

  // =========================
  // CONTROLLERS
  // =========================

  final amountController = TextEditingController();

  final sourceController = TextEditingController();

  final descriptionController = TextEditingController();

  final walletTextController = TextEditingController();

  final tagTextController = TextEditingController();

  final repeatController = TextEditingController();

  // =========================
  // STATE
  // =========================

  final selectedWallet = Rxn<WalletEntity>();

  final selectedTag = Rxn<TagEntity>();

  final selectedDate = DateTime.now().obs;

  final isLoadingSave = false.obs;

  final isWalletsSaved = false.obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();

    walletsListController.loadWallets();

    tagController.loadTags(isRefresh: true);
  }

  // =========================
  // SAVE
  // =========================

  Future<void> saveIncome() async {
    if (!_validateInputs()) {
      return;
    }

    try {
      isLoadingSave.value = true;

      int? userId;

      final userResult = await userIdUsecase.getUserId();

      bool hasError = false;

      userResult.fold((failure) {
        hasError = true;

        _handleError("خطأ في جلب المستخدم", failure.message);
      }, (id) => userId = id);

      if (hasError || userId == null) {
        return;
      }

      final finalTag = await _handleTagSelection();

      final income = IncomeEntity(
        userId: userId!,

        wallet: selectedWallet.value,

        walletId: selectedWallet.value?.walletId ?? 0,

        incomeTagId: finalTag?.id,

        tag: finalTag,

        description: descriptionController.text.trim(),

        date: selectedDate.value,

        title: _getSafeTitle(),

        amount: _getSafeAmount(),
      );

      // =========================
      // OPTIMISTIC UI
      // =========================

      // إضافة الدخل فورياً
      incomesListController.incomesList.insert(0, income);

      incomesListController.incomesList.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      incomesListController.incomesList.refresh();

      // إضافة المبلغ فورياً للمحفظة
      if (isWalletsSaved.value) {
        walletsListController.increaseWalletBalance(
          walletId: selectedWallet.value!.walletId!,
          amountFromRegular: 0.0,
          amountFromSavings: income.amount,
        );
      } else {
        walletsListController.increaseWalletBalance(
          walletId: selectedWallet.value!.walletId!,

          amountFromRegular: income.amount,
          amountFromSavings: 0.0,
        );
      }

      incomesListController.updateDashboardTotals();

      final result = await addIncomeUseCase.call(income);

      result.fold(
        (failure) {
          // rollback للدخل
          incomesListController.incomesList.remove(income);

          incomesListController.incomesList.refresh();

          // rollback للمحفظة
          walletsListController.increaseWalletBalance(
            amountFromRegular: income.amount,
            amountFromSavings: 0.0,
            walletId: selectedWallet.value!.walletId!,
          );

          incomesListController.updateDashboardTotals();

          _handleError("فشل الحفظ", failure.message);
        },

        (message) {
          HelperFunction.showSnackBar("تم بنجاح", "تم اضافة الدخل");
          incomesListController.fetchAllIncomes(isRefresh: true);
          walletsListController.loadWallets(isRefresh: true);
          resetFields();
        },
      );
    } catch (e) {
      _handleError("خطأ غير متوقع", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  // =========================
  // TAG
  // =========================

  Future<TagEntity?> _handleTagSelection() async {
    final tagName = tagTextController.text.trim();

    if (tagName.isEmpty) {
      return null;
    }

    final existing = tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );

    if (existing != null) {
      return existing;
    }

    tagActionController.nameController.text = tagName;

    await tagActionController.addTag();

    await tagController.loadTags(isRefresh: true);

    return tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
  }

  // =========================
  // VALIDATION
  // =========================

  bool _validateInputs() {
    final amount = _getSafeAmount();

    if (amount <= 0) {
      _handleError("خطأ", "أدخل مبلغ صحيح أكبر من 0");

      return false;
    }

    if (amount.isNaN || amount.isInfinite) {
      _handleError("خطأ", "قيمة المبلغ غير صالحة");

      return false;
    }

    if (selectedWallet.value == null) {
      _handleError("خطأ", "يجب اختيار محفظة");

      return false;
    }

    final wallet = selectedWallet.value;

    if (wallet == null) {
      _handleError("خطأ", "المحفظة غير موجودة");

      return false;
    }

    if (wallet.localId.isEmpty) {
      _handleError("خطأ", "معرف المحفظة غير صالح");

      return false;
    }

    final source = sourceController.text.trim();

    if (source.length > 100) {
      _handleError("خطأ", "عنوان الدخل طويل جداً");

      return false;
    }

    final description = descriptionController.text.trim();

    if (description.length > 500) {
      _handleError("خطأ", "الوصف طويل جداً");

      return false;
    }

    return true;
  }

  // =========================
  // HELPERS
  // =========================

  double _getSafeAmount() {
    return double.tryParse(amountController.text.trim()) ?? 0.0;
  }

  String _getSafeTitle() {
    final text = sourceController.text.trim();

    return text.isEmpty ? "Untitled Income" : text;
  }

  // =========================
  // RESET
  // =========================

  void resetFields() {
    amountController.clear();

    sourceController.clear();

    descriptionController.clear();

    walletTextController.clear();

    tagTextController.clear();

    repeatController.clear();

    selectedWallet.value = null;

    selectedTag.value = null;

    selectedDate.value = DateTime.now();
  }

  // =========================
  // DATE
  // =========================

  Future<void> fetchDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  // =========================
  // CLOSE
  // =========================

  @override
  void onClose() {
    amountController.dispose();

    sourceController.dispose();

    descriptionController.dispose();

    walletTextController.dispose();

    tagTextController.dispose();

    repeatController.dispose();

    super.onClose();
  }
}
