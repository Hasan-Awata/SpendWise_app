import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/domain/usecases/add_expense_usecase.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class AddExpenseController extends GetxController {
  AddExpenseController({
    required this.addUseCase,
    required this.walletsListController,
    required this.tagController,
    required this.tagActionController,
    required this.expensesListController,
  });

  final AddExpenseUsecase addUseCase;
  final WalletsListController walletsListController;
  final TagViewController tagController;
  final TagActionController tagActionController;
  final ExpensesListController expensesListController;

  final amountController = TextEditingController();
  final titleTextController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();
  final categoryTextController = TextEditingController();

  final selectedWallet = Rxn<WalletModel>();
  final selectedTag = Rxn<TagModel>();
  final selectedCategory = Rxn<CategoryModel>();
  final selectedDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(name: "Basics", priority: 1),
    CategoryModel(name: "Secondaries", priority: 2),
    CategoryModel(name: "Expenses", priority: 3),
    CategoryModel(name: "Savings", priority: 4),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    walletsListController.loadWallets();
    tagController.loadTags();
  }

  Future<void> saveExpense() async {
    if (!_isInputValid()) return;

    try {
      isLoadingSave.value = true;

      final TagModel? finalTag = await _handleTagSelection();

      final expenseData = ExpenseModel(
        userId: AppUserLocalDatasourceImpl().currentUserId,
        amount: double.parse(amountController.text.trim()),
        title: titleTextController.text.trim().isEmpty
            ? "Untitled Expense"
            : titleTextController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        category: selectedCategory.value,
        wallet: selectedWallet.value!,
        tag: finalTag,
        isSynced: false,
      );

      final result = await addUseCase.call(expenseData);

      result.fold(
        (failure) => _handleError("فشل الحفظ", failure.message),
        (_) => _onSaveSuccess(expenseData),
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<TagModel?> _handleTagSelection() async {
    final String tagName = tagTextController.text.trim();
    if (tagName.isEmpty) return null;

    final existingTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
    if (existingTag != null) return existingTag;

    tagActionController.nameController.text = tagName;
    await tagActionController.addTag();
    await tagController.loadTags();

    return tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
  }

  void _onSaveSuccess(ExpenseModel savedExpense) {
    expensesListController.expensesList.insert(0, savedExpense);
    expensesListController.calculateTotals();
    HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة المصروف الجديد");
    resetFields();
  }

  bool _isInputValid() {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty || (double.tryParse(amountText) ?? 0.0) <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح أكبر من صفر");
      return false;
    }

    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة");
      return false;
    }

    if (categoryTextController.text.isEmpty || selectedCategory.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار فئة للمصروف");
      return false;
    }

    return true;
  }

  final repeatController = TextEditingController();
  void resetFields() {
    amountController.clear();
    titleTextController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    categoryTextController.clear();
    selectedDate.value = DateTime.now();
    selectedWallet.value = null;
    selectedTag.value = null;
    selectedCategory.value = null;
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
    titleTextController.dispose();
    descriptionController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    categoryTextController.dispose();
    repeatController.dispose();
    super.onClose();
  }
}
