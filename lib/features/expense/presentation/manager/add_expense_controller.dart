// // تعليق: إضافة مصروف — مدمج مع ميزات المزامنة التلقائية للفئات والأوسمة والمحافظ
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

  // // التعديل: توحيد أسماء المتحكمات مع نمط AddIncome
  final amountController = TextEditingController();
  final titleTextController = TextEditingController(); // بمثابة Source في الدخل
  final descriptionController = TextEditingController();
  final repeatController = TextEditingController();
  final walletTextController = TextEditingController();
  final tagTextController = TextEditingController();
  final categoryTextController = TextEditingController();

  final Rxn<WalletModel> selectedWallet = Rxn<WalletModel>();
  final Rxn<TagModel> selectedTag = Rxn<TagModel>();
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final RxBool isLoadingSave = false.obs;

  // // التعديل: فئات تجريبية (يتم تحديثها لاحقاً من الـ API)
  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(name: "eating", priority: 1),
    CategoryModel(name: "car", priority: 2),
  ].obs;

  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    // مزامنة البيانات عند فتح الصفحة لضمان حداثة القوائم المنسدلة
    walletsListController.loadWallets();
    tagController.loadTags();
  }

  // // التعديل: وظيفة الحفظ مع منطق إنشاء التاج التلقائي المتبع في الدخل
  Future<void> saveExpense() async {
    if (!_isInputValid()) return;

    isLoadingSave.value = true;

    try {
      // 1. معالجة التاج (بحث أو إنشاء جديد)
      final String tagName = tagTextController.text.trim();
      var foundTag = tagController.myTags.firstWhereOrNull(
        (t) => t.name == tagName,
      );

      if (foundTag == null && tagName.isNotEmpty) {
        tagActionController.nameController.text = tagName;
        await tagActionController.addTag();
        foundTag = tagController.myTags.firstWhereOrNull(
          (t) => t.name == tagName,
        );
      }

      // 2. معالجة الفئة (Category)
      final category = categories.firstWhereOrNull(
        (c) => categoryTextController.text.contains(c.name),
      );

      // 3. بناء الموديل
      final expenseData = ExpenseModel(
        userId: userId,
        amount: double.tryParse(amountController.text.trim()) ?? 0.0,
        title: titleTextController.text.isEmpty
            ? "Untitled Expense"
            : titleTextController.text.trim(),
        description: descriptionController.text.trim(),
        date: selectedDate.value,
        category: category!,
        isSynced: false,
        // إضافة المحفظة والتاج إذا كان الموديل يدعمهما ككائنات
        wallet: selectedWallet.value,
        tag: foundTag,
      );

      final result = await addUseCase.call(expenseData);

      result.fold((failure) => _handleError("فشل الحفظ", failure.message), (_) {
        // تحديث قائمة المصروفات فوراً في الواجهة
        expensesListController.expensesList.insert(0, expenseData);
        HelperFunction.showSnackBar("تم بنجاح", "تمت إضافة المصروف الجديد");
        resetFields();
      });
    } catch (e) {
      _handleError("خطأ", "حدث خطأ غير متوقع أثناء الحفظ");
    } finally {
      isLoadingSave.value = false;
    }
  }

  // // التعديل: منطق التحقق (Validation) مشابه للدخل
  bool _isInputValid() {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      _handleError("خطأ في التحقق", "يرجى إدخال مبلغ صحيح");
      return false;
    }

    if (userId == null) {
      _handleError("خطأ", "لم يتم العثور على معرف المستخدم");
      return false;
    }

    // التحقق من المحفظة
    final walletName = walletTextController.text.trim();
    selectedWallet.value = walletsListController.wallets.firstWhereOrNull(
      (w) =>
          "${w.currency.currencyName}      (${w.currency.code} ${w.balance})"
              .trim() ==
          walletName,
    );

    if (selectedWallet.value == null) {
      _handleError("خطأ في التحقق", "يرجى اختيار محفظة صحيحة");
      return false;
    }

    // التحقق من الفئة (ميزة إضافية للمصروف)
    if (categoryTextController.text.isEmpty) {
      _handleError("خطأ في التحقق", "يرجى اختيار فئة للمصروف");
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
    repeatController.dispose();
    walletTextController.dispose();
    tagTextController.dispose();
    categoryTextController.dispose();
    super.onClose();
  }
}
