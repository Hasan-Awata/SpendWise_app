// lib/features/fixed_income/presentation/manager/fixed_income_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/add_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/delete_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/get_fixed_income_usecase.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/update_fixed_income_usecases.dart';
import 'package:spendwise/features/helper_function.dart';

class FixedIncomeController extends GetxController {
  final GetFixedIncomesUseCase getUseCase;
  final AddFixedIncomeUseCase addUseCase;
  final UpdateFixedIncomeUseCase updateUseCase;
  final DeleteFixedIncomeUseCase deleteUseCase;

  FixedIncomeController({
    required this.getUseCase,
    required this.addUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  // =========================
  // STATE
  // =========================
  final RxList<FixedIncomeModel> incomes = <FixedIncomeModel>[].obs;
  final RxBool isLoading = false.obs;

  // Controllers for Input
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final daysController = TextEditingController(); // مطابق لـ Days في الـ DTO

  final Rx<DateTime> lastTime = DateTime.now().obs;
  final RxBool isActive = true.obs;
  final RxBool isMonthly = true.obs;
  int tagId = 1; // قيمة افتراضية، يمكنك ربطها بـ Dropdown لاحقاً

  @override
  void onInit() {
    super.onInit();
    fetchIncomes();
  }

  // =========================
  // OPERATIONS
  // =========================

  Future<void> fetchIncomes() async {
    isLoading.value = true;
    final result = await getUseCase.call();
    result.fold((failure) => _handleError("خطأ", failure.message), (data) {
      incomes.assignAll(data as Iterable<FixedIncomeModel>);
      incomes.sort((a, b) => b.lastTime.compareTo(a.lastTime));
    });
    isLoading.value = false;
  }

  Future<void> saveFixedIncome() async {
    if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
      _handleError("خطأ", "يرجى تعبئة العنوان والمبلغ");
      return;
    }

    final model = FixedIncomeModel(
      fixedIncomeId: -1,
      userId: CurrentUser.userId!,
      tagId: tagId,
      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text) ?? 0.0,
      isMonthly: isMonthly.value,
      isActive: isActive.value,
      days: int.tryParse(daysController.text) ?? 1,
      lastTime: lastTime.value,
    );

    isLoading.value = true;
    final result = await addUseCase.call(model);

    result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
      incomes.insert(0, model);
      incomes.refresh();

      // تنظيف الحقول
      titleController.clear();
      amountController.clear();
      daysController.clear();

      HelperFunction.showSnackBar("نجاح", "تمت إضافة الدخل وتجهيزه للمزامنة");
      Get.back();
    });
    isLoading.value = false;
  }

  // =========================
  // HELPERS
  // =========================
  Future<void> pickDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);
    if (picked != null) lastTime.value = picked;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  Future<void> deleteFixedIncome(int isarId) async {
    final index = incomes.indexWhere((e) => e.isarId == isarId);
    if (index != -1) {
      final model = incomes[index];
      incomes.removeAt(index);

      // تنفيذ عملية الحذف عبر الـ UseCase
      final result = await deleteUseCase.call(model);
      result.fold((failure) {
        // في حال فشل الحذف، نقوم بإرجاع العنصر للقائمة
        incomes.insert(index, model);
        _handleError("فشل الحذف", failure.message);
      }, (_) => HelperFunction.showSnackBar("نجاح", "تم حذف الدخل"));
    }
  }

  // دالة التحديث: لتعديل بيانات الدخل الموجود مسبقاً
  Future<void> updateFixedIncome(FixedIncomeModel model) async {
    isLoading.value = true;
    final result = await updateUseCase.call(model);

    result.fold(
      (failure) {
        _handleError("فشل التحديث", failure.message);
      },
      (_) {
        final index = incomes.indexWhere((e) => e.isarId == model.isarId);
        if (index != -1) {
          incomes[index] = model;
          incomes.refresh();
        }
        HelperFunction.showSnackBar("نجاح", "تم تحديث بيانات الدخل");
      },
    );
    isLoading.value = false;
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    daysController.dispose();
    super.onClose();
  }
}
