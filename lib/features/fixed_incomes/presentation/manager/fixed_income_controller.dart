import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/add_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/delete_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/update_fixed_income_usecases.dart';
import 'package:spendwise/features/fixed_incomes/presentation/manager/fixed_income_list_controller.dart'; // تأكد من استيراد الـ ListController
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class FixedIncomeController extends GetxController {
  final AddFixedIncomeUseCase addUseCase;
  final UpdateFixedIncomeUseCase updateUseCase;
  final DeleteFixedIncomeUseCase deleteUseCase;
  final WalletsListController walletsListController;

  FixedIncomeController({
    required this.addUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.walletsListController,
  });

  // Inputs Controllers
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final daysController = TextEditingController();

  var lastTime = DateTime.now().obs;
  var isActionLoading = false.obs;
  var isActive = true.obs;
  var isMonthly = true.obs;
  final selectedWallet = Rxn<WalletEntity>();

  @override
  void onInit() {
    super.onInit();
    walletsListController.loadWallets();
  }

  Future<void> saveFixedIncome() async {
    if (!_validateInputs()) return;

    isActionLoading.value = true;
    try {
      final newIncome = FixedIncomeModel(
        userId: CurrentUser.userId!,
        tagId: 1, // أو القيمة المختارة
        walletId: selectedWallet.value?.walletId ?? -1,
        title: titleController.text.trim(),
        amount: double.tryParse(amountController.text) ?? 0.0,
        isMonthly: isMonthly.value,
        isActive: isActive.value,
        days: int.tryParse(daysController.text) ?? 1,
        lastTime: lastTime.value,
      );

      final result = await addUseCase.call(newIncome);
      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (success) {
          _resetFields();
          _refreshList();
          HelperFunction.showSnackBar("نجاح", "تمت إضافة الدخل بنجاح");
          Get.back();
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastTime.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) lastTime.value = picked;
  }

  Future<void> updateFixedIncome(FixedIncomeModel model) async {
    if (!_validateInputs()) return;

    isActionLoading.value = true;
    try {
      model.title = titleController.text.trim();
      model.amount = double.tryParse(amountController.text) ?? 0.0;
      model.days = int.tryParse(daysController.text) ?? 1;
      model.lastTime = lastTime.value;
      model.isActive = isActive.value;
      model.isMonthly = isMonthly.value;

      final result = await updateUseCase.call(model);
      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (success) {
          _refreshList();
          if (Get.isOverlaysOpen) Get.back();
          HelperFunction.showSnackBar("نجاح", "تم تحديث الدخل بنجاح");
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteFixedIncome(FixedIncomeModel model) async {
    // Optimistic Update
    if (Get.isRegistered<FixedIncomeListController>()) {
      Get.find<FixedIncomeListController>().incomesList.removeWhere(
        (e) => e.isarId == model.isarId,
      );
      Get.find<FixedIncomeListController>().refresh();
    }

    Get.back();
    final result = await deleteUseCase.call(model);
    result.fold((failure) {
      _refreshList();
      HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
    }, (success) => HelperFunction.showSnackBar("نجاح", "تم حذف الدخل"));
  }

  bool _validateInputs() {
    if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى تعبئة الحقول المطلوبة",
        isError: true,
      );
      return false;
    }
    return true;
  }

  void _refreshList() {
    if (Get.isRegistered<FixedIncomeListController>()) {
      Get.find<FixedIncomeListController>().fetchIncomes(isRefresh: true);
    }
  }

  void _resetFields() {
    titleController.clear();
    amountController.clear();
    daysController.clear();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    daysController.dispose();
    super.onClose();
  }
}
