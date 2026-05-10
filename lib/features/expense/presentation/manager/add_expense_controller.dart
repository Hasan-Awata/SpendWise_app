// add_expense_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/add_expense_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/tags/domain/entities/tag_entity.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';
import 'package:spendwise/features/wallet/domain/entities/wallet_entity.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';
import 'package:uuid/uuid.dart';

class AddExpenseController extends GetxController {
  AddExpenseController({
    required this.addUseCase,
    required this.walletsListController,
    required this.tagController,
    required this.tagActionController,
    required this.expensesListController,
    required this.userIdUsecase,
  });

  final GetUserIdUsecase userIdUsecase;

  final AddExpenseUsecase addUseCase;

  final WalletsListController walletsListController;

  final TagViewController tagController;

  final TagActionController tagActionController;

  final ExpensesListController expensesListController;

  // =========================
  // CONTROLLERS
  // =========================

  final amountController = TextEditingController();

  final titleTextController = TextEditingController();

  final descriptionController = TextEditingController();

  final walletTextController = TextEditingController();

  final tagTextController = TextEditingController();

  final categoryTextController = TextEditingController();

  final productsController = TextEditingController();

  final repeatController = TextEditingController();

  // =========================
  // STATE
  // =========================

  final selectedWallet = Rxn<WalletEntity>();

  final selectedTag = Rxn<TagEntity>();

  final selectedCategory = Rxn<CategoryModel>();

  final selectedDate = DateTime.now().obs;

  final isLoadingSave = false.obs;

  final isFixed = false.obs;

  final RxList<String> tempProducts = <String>[].obs;

  // =========================
  // CATEGORIES
  // =========================

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(categoryId: 1, name: "Essentials", priority: 1),

    CategoryModel(categoryId: 2, name: "Secondaries", priority: 2),

    CategoryModel(categoryId: 3, name: "Luxuries", priority: 3),

    CategoryModel(categoryId: 4, name: "Savings", priority: 4),
  ].obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();

    _loadInitialData();
  }

  void _loadInitialData() {
    walletsListController.loadWallets();

    tagController.loadTags(refresh: true);
  }

  // =========================
  // PRODUCTS
  // =========================

  void addProductToList() {
    final product = productsController.text.trim();

    if (product.isEmpty) return;

    if (tempProducts.contains(product)) {
      return;
    }

    tempProducts.add(product);

    productsController.clear();
  }

  void removeProduct(String productName) {
    tempProducts.remove(productName);
  }

  // =========================
  // SAVE
  // =========================

  Future<void> saveExpense() async {
    if (!_isInputValid()) return;

    try {
      isLoadingSave.value = true;

      final tag = await _handleTagSelection();

      int? userId;

      bool hasError = false;

      final userResult = await userIdUsecase.getUserId();

      userResult.fold(
        (failure) {
          hasError = true;

          _handleError("خطأ", failure.message);
        },
        (id) {
          userId = id;
        },
      );

      if (hasError || userId == null) {
        return;
      }

      // =====================
      // ENTITY
      // =====================

      final expense = ExpenseEntity(
        localId: const Uuid().v4(),

        userId: userId!,

        title: titleTextController.text.trim().isEmpty
            ? "Untitled Expense"
            : titleTextController.text.trim(),

        amount: double.parse(amountController.text.trim()),

        description: descriptionController.text.trim(),

        products: tempProducts.join(", "),

        date: selectedDate.value,

        walletId: selectedWallet.value?.walletId,

        wallet: selectedWallet.value,

        expenseTagId: tag?.id,

        tag: tag,

        category: selectedCategory.value,

        categoryId: selectedCategory.value?.categoryId,

        isSynced: false,
      );

      // =====================
      // OPTIMISTIC UI
      // =====================

      expensesListController.addExpenseLocally(expense);

      // =====================
      // SAVE
      // =====================

      final result = await addUseCase.call(expense);

      result.fold(
        (failure) {
          _handleError("فشل الحفظ", failure.message);
        },
        (_) {
          expensesListController.calculateTotals();

          HelperFunction.showSnackBar("تم بنجاح", "تم حفظ المصروف بنجاح");

          resetFields();
        },
      );
    } catch (e) {
      _handleError("خطأ تقني", e.toString());
    } finally {
      isLoadingSave.value = false;
      Get.find<ExpensesListController>().fetchExpenses(isRefresh: true);
    }
  }

  // =========================
  // TAGS
  // =========================

  Future<TagEntity?> _handleTagSelection() async {
    final tagName = tagTextController.text.trim();

    if (tagName.isEmpty) {
      return null;
    }

    final existingTag = tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );

    if (existingTag != null) {
      return existingTag;
    }

    tagActionController.nameController.text = tagName;

    await tagActionController.addTag();

    await tagController.loadTags(refresh: true);

    return tagController.myTags.firstWhereOrNull(
      (t) => t.name.toLowerCase() == tagName.toLowerCase(),
    );
  }

  // =========================
  // VALIDATION
  // =========================

  bool _isInputValid() {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
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

    if (selectedWallet.value!.balance < amount) {
      _handleError("خطأ في التحقق", "رصيد المحفظة غير كافي");
      return false;
    }
    return true;
  }

  // =========================
  // DATE
  // =========================

  Future<void> fetchDate(BuildContext context) async {
    final picked = await HelperFunction.chooseDate(context);

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // =========================
  // RESET
  // =========================

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

    isFixed.value = false;
  }

  // =========================
  // ERROR
  // =========================

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  // =========================
  // DISPOSE
  // =========================

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
