import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallet_controller.dart';
import '../../domain/usecases/add_income_usecase.dart';
import '../../domain/usecases/get_incomes_usecase.dart';

class IncomeController extends GetxController {
  // // Dependencies
  final AddIncomeUsecase addIncomeUseCase;
  final GetIncomesUsecase getIncomesUseCase;

  final WalletController walletController;
  final TagController tagController;

  IncomeController({
    required this.addIncomeUseCase,
    required this.getIncomesUseCase,
    required this.walletController,
    required this.tagController,
  });

  // // Form Controllers (Standard Fields)
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController repeatController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController walletTextController = TextEditingController();
  final TextEditingController tagTextController = TextEditingController();

  // // Reactive State Variables
  final Rxn<WalletModel> selectedWallet = Rxn<WalletModel>();
  final Rxn<TagModel> selectedTag = Rxn<TagModel>();
  final RxList<IncomeModel> incomesList = <IncomeModel>[].obs;

  final RxString newTagName = "".obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllIncomes();
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

  // // Data Fetching
  Future<void> fetchAllIncomes() async {
    isLoading.value = true;
    try {
      final results = await getIncomesUseCase();
      incomesList.assignAll(results);
    } catch (e) {
      _handleError("Load Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // // Date Picker
  Future<void> fetchDate(BuildContext context) async {
    final DateTime? pickedDate = await HelperFunction.chooseDate(context);
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
    }
  }

  // // Save Income
  Future<void> saveIncome() async {
    final String tagName = tagTextController.text.trim();

    var foundTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name == tagName,
    );

    if (!_isInputValid()) return;

    isLoading.value = true;
    try {
      if (foundTag == null && tagName.isNotEmpty) {
        tagController.tag.value = TagModel(userId: 0, name: tagName);
        await tagController.addtag();
        // بعد الإضافة، نسحب الكائن الجديد لربطه بالدخل
        foundTag = tagController.myTags.firstWhereOrNull(
          (t) => t.name == tagName,
        );
      }
      final double amount =
          double.tryParse(amountController.text.trim()) ?? 0.0;

      final incomeData = IncomeModel(
        wallet: selectedWallet.value,
        tag: selectedTag.value,
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        title: sourceController.text.isEmpty
            ? "Untitled Income"
            : sourceController.text.trim(),
        amount: amount,
      );

      await addIncomeUseCase(incomeData);
      incomesList.insert(0, incomeData);

      HelperFunction.showSnackBar(
        "Success",
        "Income added successfully",
        isError: false,
      );
      _resetFields();
    } catch (e) {
      _handleError("Save Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // // Validation
  bool _isInputValid() {
    final double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _handleError("Validation Error", "Please enter a valid amount.");
      return false;
    }
    if (selectedWallet.value == null) {
      _handleError("Validation Error", "Please select a wallet.");
      return false;
    }
    if (selectedTag.value == null && tagTextController.text.isEmpty) {
      _handleError("Validation Error", "Please select or type a tag.");
      return false;
    }
    return true;
  }

  void _resetFields() {
    // // تعليق: تنظيف كافة الحقول النصية والقيم المختارة بعد عملية الحفظ الناجحة
    amountController.clear();
    sourceController.clear();
    repeatController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    newTagName.value = "";
    selectedTag.value = null;
    selectedWallet.value = null;
    selectedDate.value = DateTime.now();
    tagController.myTags.clear();
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }
}
