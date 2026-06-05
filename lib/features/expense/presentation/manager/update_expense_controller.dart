import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/expense/data/models/product_model.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/update_expense_usecases.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class UpdateExpenseController extends GetxController {
  UpdateExpenseController({
    required this.updateExpenseUseCase,
    required this.expensesListController,
  });

  final UpdateExpenseUsecase updateExpenseUseCase;
  final ExpensesListController expensesListController;

  // =========================
  // LOADING
  // =========================
  final isLoadingUpdate = false.obs;

  // =========================
  // CONTROLLERS
  // =========================
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final productNameController = TextEditingController();
  final productQuantityController = TextEditingController();
  final productPriceController = TextEditingController();

  // =========================
  // DATA
  // =========================
  ExpenseEntity? currentExpense;

  final RxList<ProductModel> tempProducts = <ProductModel>[].obs;

  // =========================
  // INIT LISTENERS
  // =========================
  @override
  void onInit() {
    super.onInit();

    // تحديث المبلغ تلقائياً عند أي تغيير
    ever(tempProducts, (_) {
      amountController.text = totalAmount.toStringAsFixed(2);
    });
  }

  // =========================
  // LOAD EXPENSE FOR EDIT
  // =========================
  void setExpense(ExpenseEntity expense) {
    currentExpense = expensesListController.expensesList.firstWhere(
      (e) => e.localId == expense.localId,
    );
    titleController.text = currentExpense!.title;

    tempProducts.clear();

    final oldProducts = currentExpense!.products ?? [];

    if (oldProducts.isNotEmpty) {
      tempProducts.addAll(
        oldProducts.map(
          (e) =>
              ProductModel(name: e.name, quantity: e.quantity, price: e.price),
        ),
      );
    }

    amountController.text = totalAmount.toStringAsFixed(2);
  }

  // =========================
  // ADD PRODUCT
  // =========================
  void addProductToList() {
    final name = productNameController.text.trim();
    final qty = int.tryParse(productQuantityController.text.trim()) ?? 1;
    final price = double.tryParse(productPriceController.text.trim()) ?? 0;

    // 🔴 منع البيانات الفاسدة (سبب الـ 400 عندك)
    if (name.isEmpty || price <= 0 || qty < 1) {
      HelperFunction.showSnackBar(
        "خطأ",
        "تأكد من إدخال اسم + كمية >= 1 + سعر صحيح",
        isError: true,
      );
      return;
    }

    tempProducts.add(ProductModel(name: name, quantity: qty, price: price));

    _clearInputs();
  }

  // =========================
  // REMOVE PRODUCT
  // =========================
  void removeProduct(int index) {
    if (index < 0 || index >= tempProducts.length) return;
    tempProducts.removeAt(index);
  }

  // =========================
  // TOTAL
  // =========================
  double get totalAmount {
    return tempProducts.fold(0.0, (sum, p) => sum + (p.price * p.quantity));
  }

  // =========================
  // UPDATE EXPENSE
  // =========================
  Future<void> updateExpense() async {
    if (currentExpense == null) return;

    isLoadingUpdate.value = true;

    final updated = ExpenseEntity(
      localId: currentExpense!.localId,
      userId: currentExpense!.userId,
      wallet: currentExpense!.wallet,
      walletId: currentExpense!.walletId,
      categoryId: currentExpense!.categoryId,
      date: currentExpense!.date,
      description: currentExpense!.description,

      title: titleController.text.trim(),
      amount: totalAmount,
      products: List<ProductModel>.from(tempProducts),
    );

    final result = await updateExpenseUseCase(updated);

    result.fold(
      (failure) =>
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
      (_) {
        final index = expensesListController.expensesList.indexWhere(
          (e) => e.localId == updated.localId,
        );

        if (index != -1) {
          expensesListController.expensesList[index] = updated;
          expensesListController.expensesList.refresh();
        }

        expensesListController.updateDashboardTotals();

        Get.back();
        HelperFunction.showSnackBar("تم", "تم تحديث المصروف");
      },
    );

    isLoadingUpdate.value = false;
  }

  // =========================
  // CLEAR INPUTS
  // =========================
  void _clearInputs() {
    productNameController.clear();
    productQuantityController.clear();
    productPriceController.clear();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    productNameController.dispose();
    productQuantityController.dispose();
    productPriceController.dispose();
    super.onClose();
  }
}
