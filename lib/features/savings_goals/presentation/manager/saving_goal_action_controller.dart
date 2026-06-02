// lib/features/savings_goals/presentation/manager/saving_goal_action_controller.dart
// Controller: Manages CRUD actions for saving goals, ensuring local data persistence and queued synchronization triggers.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/add_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/delete_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/update_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class SavingGoalActionController extends GetxController {
  final AddSavingGoalUseCase addSavingGoalUseCase;
  final UpdateSavingGoalUseCase updateSavingGoalUseCase;
  final DeleteSavingGoalUseCase deleteSavingGoalUseCase;
  final GetUserIdUsecase userIdUsecase;
  final WalletsListController walletsListController;

  SavingGoalActionController({
    required this.addSavingGoalUseCase,
    required this.updateSavingGoalUseCase,
    required this.deleteSavingGoalUseCase,
    required this.userIdUsecase,
    required this.walletsListController,
  });

  final titleController = TextEditingController();
  final targetAmountController = TextEditingController();
  final currentAmountController = TextEditingController();

  var deadlineDate = DateTime.now().obs;
  var isActionLoading = false.obs;
  final selectedWallet = Rxn<WalletEntity>();

  @override
  void onInit() {
    super.onInit();
    walletsListController.loadWallets();
  }

  Future<void> addSavingGoal() async {
    if (!_validateInputs()) return;

    isActionLoading.value = true;
    try {
      final userResult = await userIdUsecase.getUserId();

      await userResult.fold(
        (failure) async =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (userId) async {
          final newGoal = SavingGoalEntity(
            userId: userId,
            title: titleController.text.trim(),
            targetAmount: double.parse(targetAmountController.text),
            currentAmount: double.tryParse(currentAmountController.text) ?? 0.0,
            deadlineDate: deadlineDate.value,
            isSynced: false.obs,
            currencyId: selectedWallet.value!.currencyId,
          );

          final result = await addSavingGoalUseCase.call(newGoal);
          result.fold(
            (failure) => HelperFunction.showSnackBar(
              "خطأ",
              failure.message,
              isError: true,
            ),
            (success) {
              _resetFields();
              _refreshList();
              HelperFunction.showSnackBar("نجاح", "تم إضافة هدف الادخار بنجاح");
              Get.back();
            },
          );
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateSavingGoal(SavingGoalEntity goal) async {
    if (!_validateInputs()) return;

    isActionLoading.value = true;
    try {
      // تحديث بيانات الكيان المحلي
      goal.title = titleController.text.trim();
      goal.targetAmount = double.parse(targetAmountController.text);
      goal.currentAmount = double.tryParse(currentAmountController.text) ?? 0.0;
      goal.deadlineDate = deadlineDate.value;

      final result = await updateSavingGoalUseCase.call(goal);

      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (success) {
          _refreshList();
          Get.back();
          HelperFunction.showSnackBar("نجاح", "تم تحديث الهدف بنجاح");
        },
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteSavingGoal(SavingGoalEntity goal) async {
    // حذف فوري من الواجهة (Optimistic Update)
    if (Get.isRegistered<SavingGoalListController>()) {
      Get.find<SavingGoalListController>().savingGoals.removeWhere(
        (g) => g.localId == goal.localId,
      );
      Get.find<SavingGoalListController>().refresh();
    }

    final result = await deleteSavingGoalUseCase.call(goal);
    result.fold(
      (failure) {
        _refreshList(); // إعادة التحميل في حال فشل الحذف لضمان تزامن البيانات
        HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
      },
      (success) {
        // HelperFunction.showSnackBar("نجاح", "تم حذف الهدف");
        if (Get.isOverlaysOpen) Get.back();
      },
    );
  }

  bool _validateInputs() {
    if (titleController.text.trim().isEmpty) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى إدخال عنوان الهدف",
        isError: true,
      );
      return false;
    }
    final target = double.tryParse(targetAmountController.text);
    if (target == null || target <= 0) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "يرجى إدخال مبلغ مستهدف صحيح",
        isError: true,
      );
      return false;
    }
    return true;
  }

  void _refreshList() {
    if (Get.isRegistered<SavingGoalListController>()) {
      Get.find<SavingGoalListController>().loadSavingGoals(isRefresh: true);
    }
  }

  void _resetFields() {
    titleController.clear();
    targetAmountController.clear();
    currentAmountController.clear();
    deadlineDate.value = DateTime.now();
  }

  @override
  void onClose() {
    titleController.dispose();
    targetAmountController.dispose();
    currentAmountController.dispose();
    super.onClose();
  }
}
