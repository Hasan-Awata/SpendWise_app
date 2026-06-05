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
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class FixedObligationController extends GetxController {
  final GetFixedObligationsUseCase getUseCase;
  final AddFixedObligationUseCase addUseCase;
  final UpdateFixedObligationUseCase updateUseCase;
  final DeleteFixedObligationUseCase deleteUseCase;
  final WalletsListController walletsListController;
  FixedObligationController({
    required this.getUseCase,
    required this.addUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.walletsListController,
  });

  // =========================
  // STATE
  // =========================
  final RxList<FixedObligationModel> obligations = <FixedObligationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDelete = false.obs;
  // Controllers for Input
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final daysController = TextEditingController();

  // أضف هذه المتغيرات في كلاس الـ Controller
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isActive = true.obs;

  final selectedWallet = Rxn<WalletEntity>();
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

  // =========================
  // OPERATIONS
  // =========================

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
      lastTime: selectedDate.value, // استخدام التاريخ المختار
      isActive: isActive.value, // استخدام الحالة المختارة
      isDeleted: false,
      isSynced: false,
      syncAttempts: 0,
      walletId: selectedWallet.value?.walletId ?? -1,
      wallet: selectedWallet.value,
      days: int.tryParse(daysController.text) ?? 1,
    );
    isLoading.value = true;
    final result = await addUseCase.call(model);

    result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
      obligations.insert(0, model);
      obligations.refresh();

      // تنظيف الحقول
      titleController.clear();
      amountController.clear();
      daysController.clear();

      HelperFunction.showSnackBar(
        "نجاح",
        "تمت إضافة الالتزام وتجهيزه للمزامنة",
      );
    });
    isLoading.value = false;
  }

  Future<void> deleteObligationLocally(FixedObligationModel entity) async {
    try {
      isLoadingDelete.value = true;

      // =====================
      // OPTIMISTIC DELETE
      // =====================

      // =====================
      // DELETE FROM DATABASE/API
      // =====================

      final result = await deleteUseCase.call(entity);

      result.fold(
        (failure) {
          _handleError("فشل الحذف", failure.message);
        },
        (_) {
          HelperFunction.showSnackBar("تم الحذف", "تم الحذف بنجاح");
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingDelete.value = false;
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
    daysController.dispose();
    super.onClose();
  }
}
