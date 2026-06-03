// lib/features/fixed_obligations/presentation/manager/fixed_obligation_controller.dart
// FixedObligationController: إدارة تفاعلية للالتزامات المالية الثابتة مع دعم العمليات المحلية (Local Operations)
// والمزامنة اللحظية لضمان تجربة مستخدم سريعة ومنع تعارض البيانات.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/current_user.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/add_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/delete_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/get_fixed_obligation_usecase.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/update_fixed_obligation_usecases.dart';
import 'package:spendwise/features/helper_function.dart';

class FixedObligationController extends GetxController {
  final GetFixedObligationsUseCase getUseCase;
  final AddFixedObligationUseCase addUseCase;
  final UpdateFixedObligationUseCase updateUseCase;
  final DeleteFixedObligationUseCase deleteUseCase;

  FixedObligationController({
    required this.getUseCase,
    required this.addUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
  });

  // =========================
  // STATE
  // =========================
  final RxList<FixedObligationModel> obligations = <FixedObligationModel>[].obs;
  final RxBool isLoading = false.obs;

  // Controllers for Input
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dayOfMonthController = TextEditingController();

  // أضف هذه المتغيرات في كلاس الـ Controller
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isActive = true.obs;

  // أضف هذه الدالة لاختيار التاريخ
  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  @override
  void onInit() {
    super.onInit();
    fetchObligations();
  }

  // =========================
  // OPERATIONS
  // =========================

  Future<void> fetchObligations() async {
    isLoading.value = true;
    final result = await getUseCase.call();
    result.fold((failure) => _handleError("خطأ", failure.message), (data) {
      obligations.assignAll(data);
      obligations.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
    isLoading.value = false;
  }

  Future<void> saveFixedObligation() async {
    if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
      _handleError("خطأ", "يرجى تعبئة العنوان والمبلغ");
      return;
    }

    final model = FixedObligationModel(
      id: -1,
      ownerId: CurrentUser.userId!,
      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text) ?? 0.0,
      dueDate: selectedDate.value, // استخدام التاريخ المختار
      isActive: isActive.value, // استخدام الحالة المختارة
      isDeleted: false,
      isSynced: false,
      syncAttempts: 0,
    );
    isLoading.value = true;
    final result = await addUseCase.call(model);

    result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
      obligations.insert(0, model);
      obligations.refresh();

      // تنظيف الحقول
      titleController.clear();
      amountController.clear();
      dayOfMonthController.clear();

      HelperFunction.showSnackBar(
        "نجاح",
        "تمت إضافة الالتزام وتجهيزه للمزامنة",
      );
      Get.back();
    });
    isLoading.value = false;
  }

  Future<void> deleteObligationLocally(int isarId) async {
    final index = obligations.indexWhere((e) => e.isarId == isarId);
    if (index != -1) {
      final model = obligations[index];
      obligations.removeAt(index);

      final result = await deleteUseCase.call(model);
      result.fold((failure) {
        obligations.insert(index, model); // استرجاع في حال الفشل
        _handleError("فشل الحذف", failure.message);
      }, (_) => HelperFunction.showSnackBar("نجاح", "تم حذف الالتزام"));
    }
  }

  // =========================
  // HELPERS
  // =========================
  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  Future<void> fetchDate(BuildContext context) async {
    final pickedDate = await HelperFunction.chooseDate(context);
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    dayOfMonthController.dispose();
    super.onClose();
  }
}
