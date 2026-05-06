// // AddExpenseController - Updated with dynamic product list logic
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/domain/usecases/add_expense_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
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
  final productsController = TextEditingController();
  final repeatController = TextEditingController();

  final selectedWallet = Rxn<WalletModel>();
  final selectedTag = Rxn<TagModel>();
  final selectedCategory = Rxn<CategoryModel>();
  final selectedDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  // // Temporary list to hold products before saving
  final RxList<String> tempProducts = <String>[].obs;

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(categoryId: 1, name: "Essentials", priority: 1),
    CategoryModel(categoryId: 2, name: "Secondaries", priority: 2),
    CategoryModel(categoryId: 3, name: "Luxuries", priority: 3),
    CategoryModel(categoryId: 4, name: "Savings", priority: 4),
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

  // // Logic to add product to the chip list
  void addProductToList() {
    String product = productsController.text.trim();
    if (product.isNotEmpty && !tempProducts.contains(product)) {
      tempProducts.add(product);
      productsController.clear();
    }
  }

  void removeProduct(String productName) {
    tempProducts.remove(productName);
  }

  Future<void> saveExpense() async {
    if (!_isInputValid()) return;

    try {
      isLoadingSave.value = true;

      final TagModel? finalTag = await _handleTagSelection();

      // // Convert list of products to a single comma-separated string for backend
      String productsString = tempProducts.join(", ");

      final expenseData = ExpenseModel(
        userId: AppUserLocalDatasourceImpl().currentUserId,
        amount: double.parse(amountController.text.trim()),
        title: titleTextController.text.trim().isEmpty
            ? "Untitled Expense"
            : titleTextController.text.trim(),
        description: descriptionController.text.trim(),
        products: productsString,
        date: selectedDate.value,
        category: selectedCategory.value,
        wallet: selectedWallet.value!,
        tag: finalTag,
        walletId: selectedWallet.value?.walletId,
        categoryId: selectedCategory.value?.categoryId,
        expenseTagId: finalTag?.id,
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
    expensesListController.fetchExpenses(isRefresh: true);
    expensesListController.calculateTotals();
    HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة المصروف الجديد");
    resetFields();
  }

  bool _isInputValid() {
    if (amountController.text.isEmpty ||
        (double.tryParse(amountController.text) ?? 0.0) <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح");
      return false;
    }
    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة");
      return false;
    }
    if (selectedCategory.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار فئة");
      return false;
    }
    return true;
  }

  void resetFields() {
    amountController.clear();
    titleTextController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    categoryTextController.clear();
    productsController.clear();
    repeatController.clear();
    tempProducts.clear();
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
    productsController.dispose();
    repeatController.dispose();
    super.onClose();
  }
}
