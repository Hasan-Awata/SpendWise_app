// expenses_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/domain/entities/expense_entity.dart';
import 'package:spendwise/features/expense/domain/usecases/get_all_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

// expenses_list_controller.dart

class ExpensesListController extends GetxController {
  final GetExpensesUsecase getExpensesUseCase;
  final GetAllLocalExpensesUsecase getAllLocalExpensesUsecase;
  final GetUserIdUsecase userIdUsecase;

  ExpensesListController({
    required this.getExpensesUseCase,
    required this.getAllLocalExpensesUsecase,
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

  // قفل لمنع التداخل بين الطلبات
  bool _isProcessing = false;

  final ScrollController scrollController = ScrollController();
  final mainController = Get.find<MainController>();
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
    ], (_) => calculateTotals());
    fetchExpenses(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;

    final position = scrollController.position;
    // التفعيل عند الاقتراب من النهاية بمسافة 100 بكسل
    if (position.pixels >= position.maxScrollExtent - 100) {
      if (!isLoadingMore.value && !isLoading.value && hasMoreData.value) {
        fetchExpenses();
      }
    }
  }

  Future<void> fetchExpenses({bool isRefresh = false}) async {
    if (_isProcessing) return;
    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing = true;
    try {
      errorMessage.value = '';

      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (expensesList.isEmpty && isRefresh) isLoading.value = true;

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
          if (expensesList.isEmpty) _loadLocalFallback(isRefresh);
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (pagedResponse) async {
          final fetchedItems = pagedResponse.data
              .where((e) => !e.isDeleted)
              .toList();
          await _cleanupDuplicateLocals(fetchedItems);
          if (isRefresh) {
            expensesList.assignAll(fetchedItems);
          } else {
            _mergeExpenses(fetchedItems);
          }

          // الترتيب من الأحدث للأقدم دائماً
          expensesList.sort((a, b) => b.date.compareTo(a.date));

          // تحديث حالة الـ Pagination
          if (fetchedItems.length < pageSize) {
            hasMoreData.value = false;
          } else {
            currentPage.value++;
          }

          calculateTotals();
        },
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing = false;
    }
  }

  Future<void> _cleanupDuplicateLocals(List<ExpenseEntity> remoteItems) async {
    final localResult = await getAllLocalExpensesUsecase.call();

    await localResult.fold((_) async {}, (allLocal) async {
      for (var remoteItem in remoteItems) {
        if (remoteItem.id == null) continue;

        final duplicates = allLocal
            .where(
              (local) =>
                  local.id == remoteItem.id &&
                  local.localId != remoteItem.localId,
            )
            .toList();

        for (var dup in duplicates) {
          expensesList.removeWhere((e) => e.localId == dup.localId);

          deleteExpenseLocally(dup.localId);
          debugPrint(
            "🔥 Duplicate deleted: ${dup.localId} for remote ID: ${dup.id}",
          );
        }
      }
    });
  }

  void _mergeExpenses(List<ExpenseEntity> newItems) {
    final Set<String> existingIds = expensesList.map((e) => e.localId).toSet();
    final List<ExpenseEntity> uniqueItems = newItems
        .where((item) => !existingIds.contains(item.localId))
        .toList();

    if (uniqueItems.isNotEmpty) {
      expensesList.addAll(uniqueItems);
    }
  }

  Future<void> _loadLocalFallback(bool isRefresh) async {
    final result = await getAllLocalExpensesUsecase.call();
    result.fold((_) {}, (localExpenses) {
      final filtered = localExpenses.where((e) => !e.isDeleted).toList();
      if (isRefresh) {
        expensesList.assignAll(filtered);
      } else {
        _mergeExpenses(filtered);
      }
      calculateTotals();
    });
  }

  // دالة الحساب المحسنة
  Future<void> calculateTotals() async {
    final result = await getAllLocalExpensesUsecase.call();
    result.fold((_) {}, (expenses) {
      final m = dashboardMonth.value.month;
      final y = dashboardMonth.value.year;
      final walletId = mainController.selectWallet.value?.walletId;

      double monthly = 0, all = 0, monthlyW = 0;

      for (var e in expenses) {
        if (e.isDeleted) continue;
        all += e.amount;
        if (e.date.month == m && e.date.year == y) {
          monthly += e.amount;
          if (walletId != null && e.walletId == walletId) {
            monthlyW += e.amount;
          }
        }
      }
      monthlyExpenseTotal.value = monthly;
      allTimeExpenseTotal.value = all;
      monthlyAndWalletExpense.value = monthlyW;
    });
  }

  // بقية الدوال المساعدة (UI Update Helpers)
  void addExpenseLocally(ExpenseEntity expense) {
    expensesList.insert(0, expense);
    calculateTotals();
  }

  void updateExpenseLocally(ExpenseEntity updatedExpense) {
    final index = expensesList.indexWhere(
      (e) => e.localId == updatedExpense.localId,
    );
    if (index != -1) {
      expensesList[index] = updatedExpense;
      expensesList.refresh();
      calculateTotals();
    }
  }

  void deleteExpenseLocally(String localId) {
    expensesList.removeWhere((e) => e.localId == localId);
    calculateTotals();
  }

  Future<void> refreshExpenses() => fetchExpenses(isRefresh: true);
  Future<void> retry() => fetchExpenses(isRefresh: true);

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
