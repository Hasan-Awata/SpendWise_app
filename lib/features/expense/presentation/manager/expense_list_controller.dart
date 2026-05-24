import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpensesListController extends GetxController {
  final GetExpensesUsecase getExpensesUseCase;
  final GetUserIdUsecase userIdUsecase;

  ExpensesListController({
    required this.getExpensesUseCase,
    required this.userIdUsecase,
  });

  final RxList<ExpenseEntity> expensesList = <ExpenseEntity>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;

  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;

  final int pageSize = 10;
  final RxBool _isProcessing = false.obs;

  final ScrollController scrollController = ScrollController();
  final MainController mainController = Get.find<MainController>();

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyExpenseTotal = 0.0.obs;
  final RxDouble allTimeExpenseTotal = 0.0.obs;
  final RxDouble monthlyAndWalletExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_scrollListener);

    everAll([
      dashboardMonth,
      mainController.selectWallet,
    ], (_) => updateTotals());

    fetchExpenses(isRefresh: true);
  }

  // =====================================================
  // SCROLL
  // =====================================================
  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing.value) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 100) {
      if (!isLoadingMore.value && !isLoading.value && hasMoreData.value) {
        fetchExpenses();
      }
    }
  }

  // =====================================================
  // FETCH (Offline-first via repository)
  // =====================================================
  Future<void> fetchExpenses({bool isRefresh = false}) async {
    if (_isProcessing.value) return;
    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing.value = true;

    try {
      errorMessage.value = '';

      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (expensesList.isEmpty && isRefresh) {
        isLoading.value = true;
      }

      // userId
      int? userId;
      final userResult = await userIdUsecase.getUserId();
      userResult.fold((_) {}, (id) => userId = id);

      final result = await getExpensesUseCase.call(
        userId,
        PageRequest(pageNumber: currentPage.value, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;

          // HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (pagedResponse) {
          final fetchedItems = pagedResponse.data;

          if (isRefresh) {
            expensesList.assignAll(fetchedItems);
          } else {
            // دمج العناصر الجديدة مع التأكد من عدم تكرار الـ localId
            final existingIds = expensesList.map((e) => e.localId).toSet();
            final uniqueNewItems = fetchedItems.where(
              (item) => !existingIds.contains(item.localId),
            );
            expensesList.addAll(uniqueNewItems);
          }

          // الترتيب حسب التاريخ (الأحدث أولاً)
          expensesList.sort((a, b) => b.date.compareTo(a.date));

          // تحديث حالة الـ Pagination
          if (fetchedItems.length < pageSize) {
            hasMoreData.value = false;
          } else {
            currentPage.value++;
          }

          updateTotals();
        },
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing.value = false;
    }
  }

  // =====================================================
  // TOTALS (same style as Income controller)
  // =====================================================
  void updateTotals() {
    final month = dashboardMonth.value.month;
    final year = dashboardMonth.value.year;
    final walletId = mainController.selectWallet.value?.walletId;

    double all = 0;
    double monthly = 0;
    double monthlyWallet = 0;

    for (final e in expensesList) {
      if (e.isDeleted) continue;

      all += e.amount;

      if (e.date.year == year && e.date.month == month) {
        monthly += e.amount;

        if (walletId != null && e.walletId == walletId) {
          monthlyWallet += e.amount;
        }
      }
    }

    allTimeExpenseTotal.value = all;
    monthlyExpenseTotal.value = monthly;
    monthlyAndWalletExpense.value = monthlyWallet;
  }

  // =====================================================
  // UI HELPERS
  // =====================================================
  void addExpenseLocally(ExpenseEntity expense) {
    expensesList.insert(0, expense);
    updateTotals();
  }

  void updateExpenseLocally(ExpenseEntity updated) {
    final index = expensesList.indexWhere((e) => e.localId == updated.localId);

    if (index != -1) {
      expensesList[index] = updated;
      expensesList.refresh();
      updateTotals();
    }
  }

  void deleteExpenseLocally(String localId) {
    expensesList.removeWhere((e) => e.localId == localId);
    updateTotals();
  }

  Future<void> refreshExpenses() => fetchExpenses(isRefresh: true);

  Future<void> retry() => fetchExpenses(isRefresh: true);

  // =====================================================
  // CLEANUP
  // =====================================================

  void updateDashboardTotals() {
    final year = dashboardMonth.value.year;
    final month = dashboardMonth.value.month;

    // إجمالي كل الأوقات (من البيانات المحملة حالياً)
    allTimeExpenseTotal.value = expensesList.fold(0.0, (s, e) => s + e.amount);

    // إجمالي الشهر المختار
    monthlyExpenseTotal.value = expensesList
        .where((i) => i.date.year == year && i.date.month == month)
        .fold(0.0, (s, e) => s + e.amount);

    // إجمالي الشهر المختار + المحفظة المختارة
    monthlyAndWalletExpense.value = expensesList
        .where((i) {
          final isSameMonth = i.date.year == year && i.date.month == month;
          final isSameWallet =
              i.wallet?.currency.currencyName ==
              mainController.selectWallet.value?.currency.currencyName;
          return isSameMonth && isSameWallet;
        })
        .fold(0.0, (s, e) => s + e.amount);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
