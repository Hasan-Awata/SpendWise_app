// lib/features/expense/presentation/manager/expense_list_controller.dart
// ExpensesListController: Reactive framework state manager guarding financial expense entries from architectural cross-contamination

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

  // =========================
  // STATE
  // =========================

  final RxList<ExpenseEntity> expensesList = <ExpenseEntity>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;

  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;

  final int pageSize = 10;

  bool _isFetching = false;

  final ScrollController scrollController = ScrollController();

  final MainController mainController = Get.find<MainController>();

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyExpenseTotal = 0.0.obs;
  final RxDouble allTimeExpenseTotal = 0.0.obs;
  final RxDouble monthlyAndWalletExpense = 0.0.obs;

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_scrollListener);

    everAll([
      dashboardMonth,
      mainController.selectWallet,
    ], (_) => updateDashboardTotals());

    fetchExpenses(isRefresh: true);
  }

  // =========================
  // SCROLL
  // =========================

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && !isLoading.value && hasMoreData.value) {
        fetchExpenses();
      }
    }
  }

  // =========================
  // FETCH
  // =========================

  Future<void> fetchExpenses({bool isRefresh = false}) async {
    if (_isFetching) return;

    if (!isRefresh && !hasMoreData.value) {
      return;
    }

    _isFetching = true;

    try {
      errorMessage.value = '';

      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        isRefreshing.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (expensesList.isEmpty) {
        isLoading.value = true;
      }

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
        },
        (pagedResponse) {
          final fetchedItems = pagedResponse.data;

          if (isRefresh) {
            expensesList.clear();
          }

          // إنشاء خريطة دمج آمنة تعتمد فقط على الـ localId كـ String منعا للتكرار الموضعي
          final Map<String, ExpenseEntity> merged = {
            for (final item in expensesList) item.localId: item,
          };

          for (final item in fetchedItems) {
            merged[item.localId] = item;
          }

          /* تنقية نوع البيانات الصارمة (Type Filtering):
             طرد أي كلاس متداخل بالخطأ مثل أهداف الادخار وترتيب الكائنات الصالحة تنازلياً.
          */
          final sorted = merged.values.whereType<ExpenseEntity>().toList()
            ..sort((a, b) {
              final dateA = a.date;
              final dateB = b.date;
              return dateB.compareTo(dateA);
            });

          expensesList.assignAll(sorted);

          hasMoreData.value = fetchedItems.length >= pageSize;

          if (hasMoreData.value) {
            currentPage.value++;
          }

          updateDashboardTotals();
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isFetching = false;
    }
  }

  // =========================
  // DASHBOARD TOTALS
  // =========================

  void updateDashboardTotals() {
    final month = dashboardMonth.value.month;
    final year = dashboardMonth.value.year;

    final activeWallet = mainController.selectWallet.value;

    double all = 0;
    double monthly = 0;
    double monthlyWallet = 0;

    final activeCurrencyCode = (activeWallet?.currency.code ?? "")
        .trim()
        .toUpperCase();
    final activeWalletIdStr = activeWallet?.walletId?.toString() ?? "";

    for (final expense in expensesList) {
      if (expense.isDeleted == true) continue;

      all += expense.amount;

      final isCurrentMonth =
          expense.date.year == year && expense.date.month == month;

      if (!isCurrentMonth) continue;

      monthly += expense.amount;

      if (activeWallet == null) continue;

      // مقارنة المعرفات النصية الموحدة لتجنب بقاء النتيجة صفرية
      final isSameWalletId =
          (expense.walletId?.toString() == activeWalletIdStr) ||
          (expense.wallet?.walletId?.toString() == activeWalletIdStr);

      final isSameCurrency =
          (expense.wallet?.currency.code ?? "").trim().toUpperCase() ==
          activeCurrencyCode;

      if (isSameWalletId || isSameCurrency) {
        monthlyWallet += expense.amount;
      }
    }

    allTimeExpenseTotal.value = all;
    monthlyExpenseTotal.value = monthly;
    monthlyAndWalletExpense.value = monthlyWallet;

    expensesList.refresh();
  }

  // =========================
  // LOCAL OPERATIONS
  // =========================

  void addExpenseLocally(ExpenseEntity expense) {
    final exists = expensesList.any((e) => e.localId == expense.localId);

    if (exists) return;

    expensesList.insert(0, expense);
    expensesList.sort((a, b) => b.date.compareTo(a.date));
    expensesList.refresh();
    updateDashboardTotals();
  }

  void updateExpenseLocally(ExpenseEntity updated) {
    final index = expensesList.indexWhere((e) => e.localId == updated.localId);

    if (index == -1) return;

    expensesList[index] = updated;
    expensesList.sort((a, b) => b.date.compareTo(a.date));
    expensesList.refresh();
    updateDashboardTotals();
  }

  void deleteExpenseLocally(String localId) {
    expensesList.removeWhere((e) => e.localId == localId);
    expensesList.refresh();
    updateDashboardTotals();
  }

  // =========================
  // SYNC UPDATE
  // =========================

  void markExpenseAsSynced({required String localId, int? serverId}) {
    final index = expensesList.indexWhere((e) => e.localId == localId);

    if (index == -1) return;

    final expense = expensesList[index];
    expense.isSynced.value = true;

    if (serverId != null) {
      expense.id = serverId;
    }

    expensesList.refresh();
    updateDashboardTotals();
  }

  // =========================
  // HELPERS
  // =========================

  Future<void> refreshExpenses() async {
    await fetchExpenses(isRefresh: true);
  }

  Future<void> retry() async {
    await fetchExpenses(isRefresh: true);
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
