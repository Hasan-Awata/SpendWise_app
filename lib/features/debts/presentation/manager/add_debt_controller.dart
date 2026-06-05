import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_by_user_name_usecase.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/debts/domain/usecases/add_debt_usecase.dart'
    show AddDebtUseCase;
import 'package:spendwise/features/debts/presentation/manager/debts_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:uuid/uuid.dart';

enum DebtRole { creditor, debtor }

class AddDebtController extends GetxController {
  AddDebtController({
    required this.addDebtUseCase,
    required this.userIdUsecase,
    required this.walletsListController,
    required this.debtsListController,
    required this.getUserByUsernameUseCase,
  });

  final AddDebtUseCase addDebtUseCase;
  final GetUserIdUsecase userIdUsecase;
  final GetUserByUsernameUseCase getUserByUsernameUseCase;
  final WalletsListController walletsListController;
  final DebtsListController debtsListController;

  // =========================
  // INPUTS
  // =========================

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final userNameController = TextEditingController();

  // =========================
  // STATE
  // =========================

  final role = DebtRole.creditor.obs;

  final selectedWallet = Rxn<WalletEntity>();
  final dueDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  @override
  void onInit() {
    super.onInit();
    walletsListController.loadWallets();
  }

  Future<void> saveDebt() async {
    if (!_validate()) return;

    try {
      isLoadingSave.value = true;

      final myUserId = await userIdUsecase.getUserId();
      int me = myUserId.getOrElse(() => -1);

      final debtorResult = await getUserByUsernameUseCase.call(
        userNameController.text.trim(),
      );

      int otherUserId = -1;

      debtorResult.fold(
        (_) => otherUserId = -1,
        (user) => otherUserId = user.userId,
      );

      if (otherUserId == -1) {
        _error("المستخدم غير موجود");
        return;
      }

      int creditorId;
      int debtorId;

      if (role.value == DebtRole.creditor) {
        creditorId = me;
        debtorId = otherUserId;
      } else {
        creditorId = otherUserId;
        debtorId = me;
      }

      final debt = SharedDebtEntity(
        creditorId: creditorId,
        debtorId: debtorId,
        amount: _amount(),
        title: _title(),
        status: "Pending",
        dueDate: dueDate.value,
        createdAt: DateTime.now(),
        creditorWalletId: role.value == DebtRole.creditor
            ? selectedWallet.value?.walletId
            : null,
        debtorWalletId: role.value == DebtRole.debtor
            ? selectedWallet.value?.walletId
            : null,
        paidAmount: 0,
        localId: const Uuid().v4(),
      );

      debtsListController.debts.insert(0, debt);
      debtsListController.debts.refresh();

      final result = await addDebtUseCase(debt);

      result.fold(
        (f) {
          debtsListController.debts.remove(debt);
          _error(f.message);
        },
        (_) {
          HelperFunction.showSnackBar("نجاح", "تم إضافة الدين");
          reset();
        },
      );
    } finally {
      isLoadingSave.value = false;
    }
  }

  bool _validate() {
    if (_amount() <= 0) return _error("مبلغ غير صحيح");
    if (userNameController.text.isEmpty) return _error("ادخل اسم المستخدم");
    if (selectedWallet.value == null) return _error("اختر محفظة");
    return true;
  }

  double _amount() => double.tryParse(amountController.text) ?? 0;
  String _title() =>
      titleController.text.isEmpty ? "Debt" : titleController.text;

  bool _error(String msg) {
    HelperFunction.showSnackBar("خطأ", msg, isError: true);
    return false;
  }

  Future<void> selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dueDate.value = picked;
    }
  }

  void reset() {
    titleController.clear();
    amountController.clear();
    userNameController.clear();
    selectedWallet.value = null;
    role.value = DebtRole.creditor;
  }
}
