// // [Controller logic to handle saving goals actions with proper validation and UI synchronization]
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/add_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/delete_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/update_saving_goal_usecase.dart';
import 'package:spendwise/features/savings_goals/presentation/manager/saving_goal_lis_controller.dart';

class SavingGoalActionController extends GetxController {
  final AddSavingGoalUseCase addSavingGoalUseCase;
  final UpdateSavingGoalUseCase updateSavingGoalUseCase;
  final DeleteSavingGoalUseCase deleteSavingGoalUseCase;
  final GetUserIdUsecase userIdUsecase;

  SavingGoalActionController({
    required this.addSavingGoalUseCase,
    required this.updateSavingGoalUseCase,
    required this.deleteSavingGoalUseCase,
    required this.userIdUsecase,
  });

  final titleController = TextEditingController();
  final targetAmountController = TextEditingController();
  final currentAmountController = TextEditingController();
  var deadlineDate = DateTime.now().obs;

  var isActionLoading = false.obs;

  Future<void> addSavingGoal() async {
    if (!_validateInputs()) return;

    try {
      int? userId;
      bool hasError = false;
      final userResult = await userIdUsecase.getUserId();
      userResult.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "خطأ في جلب المستخدم",
            failure.message,
            isError: true,
          );
          hasError = true;
        },
        (id) {
          userId = id;
        },
      );
      if (hasError || userId == null) {
        isActionLoading.value = false;
        return;
      }

      isActionLoading.value = true;
      final newGoal = SavingGoalEntity(
        userId: userId!,
        title: titleController.text.trim(),
        targetAmount: double.parse(targetAmountController.text),
        currentAmount: double.parse(
          currentAmountController.text.isEmpty
              ? "0"
              : currentAmountController.text,
        ),
        deadlineDate: deadlineDate.value,
        isSynced: false,
      );

      final result = await addSavingGoalUseCase.call(newGoal);

      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (successMessage) {
          _resetFields();
          _refreshList();
          HelperFunction.showSnackBar("نجاح", "تم إضافة هدف الادخار بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "حدث خطأ غير متوقع", isError: true);
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateSavingGoal(SavingGoalEntity goal) async {
    if (!_validateInputs()) return;

    try {
      isActionLoading.value = true;

      goal.title = titleController.text.trim();
      goal.targetAmount = double.parse(targetAmountController.text);
      goal.currentAmount = double.parse(
        currentAmountController.text.isEmpty
            ? "0"
            : currentAmountController.text,
      );
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
    } catch (e) {
      HelperFunction.showSnackBar(
        "خطأ",
        "فشل في تحديث البيانات",
        isError: true,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deleteSavingGoal(SavingGoalEntity goal) async {
    try {
      final result = await deleteSavingGoalUseCase.call(goal);

      result.fold(
        (failure) =>
            HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
        (success) {
          if (Get.isRegistered<SavingGoalListController>()) {
            Get.find<SavingGoalListController>().savingGoals.removeWhere(
              (g) => g.localId == goal.localId,
            );
          }
          HelperFunction.showSnackBar("نجاح", "تم حذف الهدف");
          if (Get.isOverlaysOpen) Get.back();
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", "فشل عملية الحذف", isError: true);
    }
  }

  bool _validateInputs() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
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
