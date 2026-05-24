// =========================================================================
// UpdateCategoryBudgetController
// =========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart'
    show CategoryBudgetEntity;
import 'package:spendwise/features/budget/domain/usecases/update_category_budget_usecase.dart';
import 'package:spendwise/features/helper_function.dart';

class UpdateCategoryBudgetController extends GetxController {
  final UpdateCategoryBudgetUsecase updateBudgetUseCase;

  UpdateCategoryBudgetController({required this.updateBudgetUseCase});

  final formKey = GlobalKey<FormState>();

  final percentageController = TextEditingController();

  final isLoading = false.obs;

  late CategoryBudgetEntity budget;

  void setBudget(CategoryBudgetEntity currentBudget) {
    budget = currentBudget;

    percentageController.text = currentBudget.percentageLimit.toString();
  }

  Future<void> updateBudget({
    required DateTime startDate,
    required DateTime endDate,
    required bool isActive,
  }) async {
    try {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      final updated = budget.copyWith(
        percentageLimit: double.parse(percentageController.text),
        startDate: startDate,
        endDate: endDate,
        isActive: isActive,
      );

      final result = await updateBudgetUseCase(updated);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "خطأ",
            _mapFailure(failure),
            isError: true,
          );
        },
        (_) {
          Get.back(result: true);

          HelperFunction.showSnackBar("نجاح", "تم تعديل الميزانية بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFailure(Failure failure) {
    return failure.message;
  }

  @override
  void onClose() {
    percentageController.dispose();
    super.onClose();
  }
}
