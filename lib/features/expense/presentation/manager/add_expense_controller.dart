import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';
import 'package:spendwise/features/category/data/models/category_model.dart';
import 'package:spendwise/features/expense/data/models/product_model.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/add_expense_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/ocr/ocr_result.dart';
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
  final titleTextController = TextEditingController();
  final descriptionController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();
  final categoryTextController = TextEditingController();
  final repeatController = TextEditingController();
  final productNameController = TextEditingController();
  final productQuantityController = TextEditingController();
  final productPriceController = TextEditingController();

  // =========================
  // STATE
  // =========================
  final selectedWallet = Rxn<WalletEntity>();
  final selectedTag = Rxn<TagEntity>();
  final selectedCategory = Rxn<CategoryModel>();
  final selectedDate = DateTime.now().obs;
  final isLoadingSave = false.obs;

  final totalCalculatedAmount = 0.0.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(categoryId: 1, name: "Essentials", priority: 1),
    CategoryModel(categoryId: 2, name: "Secondaries", priority: 2),
    CategoryModel(categoryId: 3, name: "Luxuries", priority: 3),
    CategoryModel(categoryId: 4, name: "Savings", priority: 4),
  ].obs;

  final RxList<ProductModel> tempProducts = <ProductModel>[].obs;

  // ... (إبقاء دوال addProductToList, removeProduct, _updateAmountBasedOnProducts كما هي)

  @override
  void onInit() {
    super.onInit();
    // التحقق إذا كانت هناك بيانات مرسلة من شاشة الـ OCR
    if (Get.arguments is OcrResult) {
      populateFromOcr(Get.arguments as OcrResult);
    }
  }

  // =========================
  // SAVE
  // =========================
  Future<void> saveExpense() async {
    if (!_isInputValid()) return;
    // 1. التحقق من الميزانية قبل المتابعة
    final categoryId = selectedCategory.value?.categoryId;
    if (categoryId != null) {
      final exceeded = await _isBudgetExceeded(
        categoryId,
        totalCalculatedAmount.value,
      );

      if (exceeded) {
        // إظهار تنبيه للمستخدم
        bool proceed = await HelperFunction.showConfirmationDialog(
          "تنبيه ميزانية",
          "هذا المصروف سيتجاوز الميزانية المحددة لهذه الفئة. هل تريد المتابعة؟",
        );

        if (!proceed) return; // إيقاف الحفظ إذا رفض المستخدم
      }
    }
    try {
      isLoadingSave.value = true;

      int? userId;

      final userResult = await userIdUsecase.getUserId();

      userResult.fold(
        (failure) => _handleError("خطأ", failure.message),
        (id) => userId = id,
      );

      if (userId == null) {
        return;
      }

      final finalAmount = double.parse(
        totalCalculatedAmount.value.toStringAsFixed(2),
      );

      final wallet = selectedWallet.value!;

      final fromRegular = wallet.balance >= finalAmount
          ? finalAmount
          : wallet.balance;

      final fromSavings = wallet.balance >= finalAmount
          ? 0.0
          : finalAmount - wallet.balance;

      final expense = ExpenseEntity(
        localId: const Uuid().v4(),
        userId: userId!,
        title: titleTextController.text.trim().isEmpty
            ? "Untitled Expense"
            : titleTextController.text.trim(),
        amount: finalAmount,
        amountFromRegular: fromRegular,
        amountFromSavings: fromSavings,
        description: descriptionController.text.trim(),
        products: List.from(tempProducts),
        date: selectedDate.value,
        walletId: wallet.walletId,
        walletLocalId: wallet.localId,
        wallet: wallet,
        expenseTagId: selectedTag.value?.id,
        tag: selectedTag.value,
        categoryId: selectedCategory.value?.categoryId,
        category: selectedCategory.value,
        isSynced: false.obs,
        isDeleted: false,
      );

      final result = await addUseCase.call(expense);

      result.fold(
        (failure) {
          _handleError("فشل الحفظ", failure.message);
        },
        (_) async {
          expensesListController.addExpenseLocally(expense);

          final balanceUpdated = await walletsListController
              .decreaseWalletBalance(
                walletId: wallet.walletId!,
                amount: expense.amount,
              );

          if (!balanceUpdated) {
            expensesListController.deleteExpenseLocally(expense.localId);

            _handleError("خطأ", "فشل تحديث رصيد المحفظة");

            return;
          }

          expensesListController.updateDashboardTotals();

          HelperFunction.showSnackBar(
            "تم بنجاح",
            "تم حفظ المصروف وتحديث الرصيد",
            isError: false,
          );

          resetFields();
        },
      );
    } catch (e) {
      _handleError("خطأ غير متوقع", e.toString());
    } finally {
      isLoadingSave.value = false;
    }
  }

  Future<bool> _isBudgetExceeded(int categoryId, double newAmount) async {
    final budgetListController = Get.find<CategoryBudgetListController>();
    final budget = budgetListController.getBudgetByCategoryId(categoryId);

    if (budget == null || !budget.isActive) {
      return false;
    }

    double currentSpending = budget.spendingProgress;
    double totalExpected = currentSpending + newAmount;

    if (totalExpected > budget.moneyLimit) {
      return true;
    }
    return false;
  }

  // =========================
  // PRODUCTS
  // =========================
  void addProductToList() {
    final name = productNameController.text.trim();
    if (name.isEmpty) {
      _handleError("خطأ", "يرجى إدخال اسم المنتج");
      return;
    }

    // استخراج القيم من المدخلات
    final quantity = int.tryParse(productQuantityController.text.trim()) ?? 1;
    final unitPrice =
        double.tryParse(productPriceController.text.trim()) ?? 0.0;

    if (quantity <= 0) {
      _handleError("خطأ", "الكمية يجب أن تكون أكبر من صفر");
      return;
    }
    if (unitPrice < 0) {
      _handleError("خطأ", "السعر غير صالح");
      return;
    }

    // هنا نقوم بحساب السعر الإجمالي للمنتج الواحد (سعر الوحدة * الكمية)
    // كما طلبت: العصير (2) * سعر (2) = 4
    final totalPriceForProduct = unitPrice * quantity;

    // نقوم بتخزين الإجمالي في الـ model الخاص بالمنتج
    final product = ProductModel(
      name: name,
      quantity: quantity,
      price: totalPriceForProduct, // تخزين الإجمالي في حقل الـ price
    );

    tempProducts.add(product);

    // تنظيف الحقول
    productNameController.clear();
    productQuantityController.clear();
    productPriceController.clear();

    // تحديث المجموع الكلي للـ amount
    _updateAmountBasedOnProducts();
  }

  void removeProduct(int index) {
    if (index < 0 || index >= tempProducts.length) return;
    tempProducts.removeAt(index);
    _updateAmountBasedOnProducts();
  }

  // =========================
  // AMOUNT
  // =========================
  void _updateAmountBasedOnProducts() {
    // تعليق: بما أن الـ price في الـ ProductModel أصبح يمثل (السعر الكلي للمنتج)،
    // نقوم فقط بجمع الـ price لكل المنتجات في القائمة.
    double total = 0.0;
    for (final product in tempProducts) {
      total += product.price;
    }

    // تعليق: تحديث الـ totalCalculatedAmount ليساوي مجموع أسعار كل المنتجات المضافة
    totalCalculatedAmount.value = double.parse(total.toStringAsFixed(2));
  }

  bool _isInputValid() {
    if (tempProducts.isEmpty) {
      _handleError("خطأ في المدخلات", "يرجى إضافة منتج واحد على الأقل");
      return false;
    }
    final wallet = selectedWallet.value;
    if (wallet == null) {
      _handleError("خطأ", "اختر محفظة");
      return false;
    }
    if (selectedCategory.value == null) {
      _handleError("خطأ", "اختر فئة");
      return false;
    }
    final totalAmount = double.parse(
      totalCalculatedAmount.value.toStringAsFixed(2),
    );
    if (totalAmount <= 0) {
      _handleError("خطأ", "إجمالي المنتجات يجب أن يكون أكبر من صفر");
      return false;
    }
    for (final product in tempProducts) {
      if (product.name.trim().isEmpty) {
        _handleError("خطأ", "يوجد منتج بدون اسم");
        return false;
      }
      if (product.quantity <= 0) {
        _handleError("خطأ", "كمية المنتج ${product.name} غير صالحة");
        return false;
      }
      if (product.price < 0) {
        _handleError("خطأ", "سعر المنتج ${product.name} غير صالح");
        return false;
      }
    }
    return true;
  }

  // =========================
  // RESET
  // =========================
  void resetFields() {
    titleTextController.clear();
    descriptionController.clear();
    walletTextController.clear();
    tagTextController.clear();
    categoryTextController.clear();
    repeatController.clear();
    productNameController.clear();
    productQuantityController.clear();
    productPriceController.clear();
    tempProducts.clear();
    totalCalculatedAmount.value = 0.0;
    selectedDate.value = DateTime.now();
    selectedWallet.value = null;
    selectedTag.value = null;
    selectedCategory.value = null;
  }

  // =========================
  // DATE PICKER
  // =========================
  Future<void> fetchDate(BuildContext context) async {
    final pickedDate = await HelperFunction.chooseDate(context);
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  // =========================
  // ERROR
  // =========================
  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  void populateFromOcr(OcrResult result) {
    // تعليق: تعبئة حقول نموذج إضافة المصروف بالبيانات المستخرجة من الإيصال
    titleTextController.text = result.title;

    // تحويل المنتجات المستخرجة إلى القائمة المؤقتة
    tempProducts.clear();
    for (var p in result.products) {
      tempProducts.add(
        ProductModel(
          // استخدام المفاتيح (Keys) الخاصة بالـ Map
          name: p['name'] ?? 'منتج غير معروف',
          price: (p['price'] as num?)?.toDouble() ?? 0.0,
          quantity: (p['quantity'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    _updateAmountBasedOnProducts();
  }

  // =========================
  // CLOSE
  // =========================
  @override
  void onClose() {
    titleTextController.dispose();
    descriptionController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    categoryTextController.dispose();
    repeatController.dispose();
    productNameController.dispose();
    productQuantityController.dispose();
    productPriceController.dispose();
    super.onClose();
  }
}
