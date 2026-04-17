// // تعليق: متحكم عرض قائمة المصاريف مع دعم الـ Offline وإحصائيات الشهر
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/expense/domain/usecases/get_all_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/sync_expense_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class ExpensesListController extends GetxController {
  ExpensesListController({
    required this.getExpensesUseCase,
    required this.getAllLocalExpensesUsecase,
    required this.syncExpenseUsecase,
  });

  final GetExpensesUsecase getExpensesUseCase;
  final GetAllLocalExpensesUsecase getAllLocalExpensesUsecase;
  final SyncPendingExpensesUsecase syncExpenseUsecase;

  final RxList<ExpenseModel> expensesList = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  // المتغيرات المالية
  final RxDouble monthlyExpenseTotal = 0.0.obs;
  final RxDouble allTimeExpenseTotal = 0.0.obs;

  final ScrollController scrollController = ScrollController();
  final int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchExpenses();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      fetchExpenses();
    }
  }

  Future<void> fetchExpenses({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (isLoading.value && !isRefresh)) return;

    isLoading.value = true;

    syncExpenseUsecase.call().then((result) {
      result.fold(
        (l) => debugPrint("Background Sync Failed: ${l.message}"),
        (r) => debugPrint("Background Sync Completed"),
      );
    });

    final result = await getExpensesUseCase.call(
      userId,
      PageRequest(pageNumber: currentPage.value, pageSize: 10),
    );

    result.fold(
      (failure) =>
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
      (pagedResponse) {
        if (isRefresh) expensesList.clear();
        expensesList.addAll(pagedResponse.data);
        if (currentPage.value >= pagedResponse.totalPages) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      },
    );

    isLoading.value = false;
    await calculateTotals(); // تحديث الحسابات بعد جلب البيانات
  }

  // في ExpensesListController
  Future<void> calculateTotals() async {
    final result = await getAllLocalExpensesUsecase.call();
    result.fold(
      (_) {
        monthlyExpenseTotal.value = 0.0;
        allTimeExpenseTotal.value = 0.0;
      },
      (allLocalExpense) {
        // استخدام القيم الحالية في الـ Observable مباشرة
        final targetYear = dashboardMonth.value.year;
        final targetMonth = dashboardMonth.value.month;

        double allTime = 0.0;
        double monthly = 0.0;

        for (var item in allLocalExpense) {
          allTime += item.amount;
          if (item.date.year == targetYear && item.date.month == targetMonth) {
            monthly += item.amount;
          }
        }

        allTimeExpenseTotal.value = allTime;
        monthlyExpenseTotal.value = monthly;
      },
    );
  }

  // دالة لتغيير الشهر وتحديث الحسابات
  void changeDashboardMonth(DateTime newDate) {
    dashboardMonth.value = newDate;
    calculateTotals();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
