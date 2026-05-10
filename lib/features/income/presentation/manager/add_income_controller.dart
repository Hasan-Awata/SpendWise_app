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
  // Controllers
  // =========================

  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();
  final repeatController = TextEditingController();

  // =========================
  // State
  // =========================

  final selectedWallet = Rxn<WalletEntity>();
  final selectedTag = Rxn<TagEntity>();
  final selectedDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  // =========================
  // Init
  // =========================

  @override
  void onInit() {
    super.onInit();
    walletsListController.loadWallets();
    tagController.loadTags(refresh: true);
  }

  // =========================
  // Save Income
  // =========================

  Future<void> saveIncome() async {
    if (!_validateInputs()) return;

    try {
      isLoadingSave.value = true;

      final userResult = await userIdUsecase.getUserId();

      int? userId;
      bool hasError = false;

      userResult.fold((failure) {
        _handleError("خطأ في جلب المستخدم", failure.message);
        hasError = true;
      }, (id) => userId = id);

      if (hasError || userId == null) return;

      final TagEntity? finalTag = await _handleTagSelection();

      final incomeData = IncomeEntity(
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

      final result = await addIncomeUseCase.call(incomeData);

      result.fold(
        (failure) => _handleError("فشل الحفظ", failure.message),
        (saved) => _onSaveSuccess(saved),
      );
    } catch (e) {
      _handleError("خطأ غير متوقع", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  // =========================
  // Tag Handling
  // =========================

  Future<TagEntity?> _handleTagSelection() async {
    final tagName = tagTextController.text.trim();
    if (tagName.isEmpty) return null;

    final existing = tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );

    if (existing != null) return existing;

    tagActionController.nameController.text = tagName;
    await tagActionController.addTag();
    await tagController.loadTags(refresh: true);

    return tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
  }

  // =========================
  // Validation
  // =========================

  bool _validateInputs() {
    if (_getSafeAmount() <= 0) {
      _handleError("خطأ", "أدخل مبلغ صحيح أكبر من 0");
      return false;
    }

    if (selectedWallet.value == null) {
      _handleError("خطأ", "يجب اختيار محفظة");
      return false;
    }

    return true;
  }

  double _getSafeAmount() {
    return double.tryParse(amountController.text.trim()) ?? 0.0;
  }

  String _getSafeTitle() {
    final text = sourceController.text.trim();
    return text.isEmpty ? "Untitled Income" : text;
  }

  // =========================
  // Success
  // =========================

  void _onSaveSuccess(String message) {
    incomesListController.fetchAllIncomes(isRefresh: true);
    incomesListController.calculateTotals();

    HelperFunction.showSnackBar("تم بنجاح", message);

    resetFields();
  }

  // =========================
  // Reset
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
  // Date Picker
  // =========================

  Future<void> fetchDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);
    if (picked != null) selectedDate.value = picked;
  }

  // =========================
  // Error
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  // =========================
  // Dispose
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
