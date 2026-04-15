// // تعليق: إضافة دخل — منفصل عن القائمة والتعديل والحذف
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/add_income_usecase.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:spendwise/features/income/presentation/manager/incomes_list_controller.dart';

class AddIncomeController extends GetxController {
  AddIncomeController({
    required this.addIncomeUseCase,
    required this.walletsListController,
    required this.tagController,
    required this.incomesListController,
  });

  final AddIncomeUsecase addIncomeUseCase;
  final WalletsListController walletsListController;
  final TagController tagController;
  final IncomesListController incomesListController;

  final amountController = TextEditingController();
  final sourceController = TextEditingController();
  final repeatController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();

  final Rxn<WalletModel> selectedWallet = Rxn<WalletModel>();
  final Rxn<TagModel> selectedTag = Rxn<TagModel>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final RxBool isLoadingSave = false.obs;

  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  Future<void> saveIncome() async {
    if (!_isInputValid()) return;

    isLoadingSave.value = true;

    final String tagName = tagTextController.text.trim();
    var foundTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name == tagName,
    );

    if (foundTag == null && tagName.isNotEmpty) {
      tagController.tag.value = TagModel(userId: userId ?? 0, name: tagName);
      await tagController.addtag();
      foundTag = tagController.myTags.firstWhereOrNull(
        (t) => t.name == tagName,
      );
    }

    final incomeData = IncomeModel(
      userId: userId,
      wallet: selectedWallet.value!,
      tag: foundTag ?? selectedTag.value,
      description: descriptionController.text.trim(),
      date: selectedDate.value,
      title: sourceController.text.isEmpty
          ? "Untitled Income"
          : sourceController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
    );

    final result = await addIncomeUseCase.call(incomeData);

    result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
      incomesListController.incomesList.insert(0, incomeData);
      incomesListController.refreshMonthlyIncomeTotal();
      HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة الدخل الجديد");
      resetFields();
    });
    isLoadingSave.value = false;
  }

  bool _isInputValid() {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح");
      return false;
    }

    final walletName = walletTextController.text.trim();
    selectedWallet.value = walletsListController.wallets.firstWhereOrNull(
      (w) =>
          "${w.currency.currencyName}      (${w.currency.code} ${w.balance})"
              .trim() ==
          walletName,
    );
    if (userId == null) {
      _handleError("Faild", "No User id");
      return false;
    }
    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة صحيحة");
      return false;
    }
    return true;
  }

  void resetFields() {
    amountController.clear();
    sourceController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    selectedDate.value = DateTime.now();
    selectedWallet.value = null;
    selectedTag.value = null;
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  Future<void> fetchDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);
    if (picked != null) selectedDate.value = picked;
  }

  @override
  void onClose() {
    amountController.dispose();
    sourceController.dispose();
    repeatController.dispose();
    descriptionController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    super.onClose();
  }
}
