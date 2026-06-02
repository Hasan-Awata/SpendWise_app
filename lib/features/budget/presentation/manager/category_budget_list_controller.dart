import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/domain/usecases/get_category_budget_usecase.dart';

class CategoryBudgetListController extends GetxController {
  final GetAllCategoryBudgetsUseCase getBudgetsUseCase;

  CategoryBudgetListController({required this.getBudgetsUseCase});

  // =========================================================
  // STATE
  // =========================================================
  final RxList<CategoryBudgetEntity> budgets = <CategoryBudgetEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool _isProcessing = false.obs;

  final ScrollController scrollController = ScrollController();

  // =========================================================
  // LIFECYCLE
  // =========================================================
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadBudgets(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (_isProcessing.value) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      // Logic for pagination if needed
    }
  }

  // =========================================================
  // LOAD
  // =========================================================
  Future<void> loadBudgets({bool isRefresh = false}) async {
    if (_isProcessing.value) return;
    if (!isRefresh && budgets.isNotEmpty) return;

    _isProcessing.value = true;
    try {
      errorMessage.value = null;
      if (isRefresh) isRefreshing.value = true;
      if (budgets.isEmpty) isLoading.value = true;

      final result = await getBudgetsUseCase.call();

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (data) {
          // [Comment: ترتيب البيانات بعد جلبها من السيرفر أو القاعدة المحلية]
          final sorted = List<CategoryBudgetEntity>.from(data)
            ..sort((a, b) => a.categoryId.compareTo(b.categoryId));
          budgets.assignAll(sorted);
        },
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      _isProcessing.value = false;
    }
  }

  // =========================================================
  // HELPERS
  // =========================================================
  CategoryBudgetEntity? getBudgetByCategoryId(int categoryId) {
    return budgets.firstWhereOrNull((e) => e.categoryId == categoryId);
  }

  // [Comment: تحديث محلي للميزانية يتضمن القيم المحسوبة (MoneyLimit, SpendingProgress)]
  void updateLocalBudget(CategoryBudgetEntity budget) {
    final index = budgets.indexWhere((e) => e.categoryId == budget.categoryId);
    if (index != -1) {
      // تحديث العنصر الموجود بالبيانات الجديدة المحسوبة بالكامل
      budgets[index] = budget;
    } else {
      budgets.add(budget);
    }
    // إعادة ترتيب القائمة لضمان تناسق العرض
    budgets.sort((a, b) => a.categoryId.compareTo(b.categoryId));
    budgets.refresh();
  }

  void removeLocalBudget(int categoryId) {
    budgets.removeWhere((e) => e.categoryId == categoryId);
    budgets.refresh();
  }
}
