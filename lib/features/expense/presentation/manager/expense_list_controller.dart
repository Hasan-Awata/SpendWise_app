import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/category/data/model/category_model.dart';
import 'package:spendwise/features/expense/data/models/expense_model.dart';
import 'package:spendwise/features/expense/domain/usecases/get_all_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:spendwise/features/expense/domain/usecases/sync_expense_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class ExpensesListController extends GetxController {
  final GetExpensesUsecase getExpensesUseCase;
  final GetAllLocalExpensesUsecase getAllLocalExpensesUsecase;
  final SyncPendingExpensesUsecase syncExpenseUsecase;

  ExpensesListController({
    required this.getExpensesUseCase,
    required this.getAllLocalExpensesUsecase,
    required this.syncExpenseUsecase,
  });

  final RxList<ExpenseModel> expensesList = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  // المتغيرات المالية
  final RxDouble monthlyExpenseTotal = 0.0.obs;
  final RxDouble allTimeExpenseTotal = 0.0.obs;

  final ScrollController scrollController = ScrollController();
  final int? userId = AppUserLocalDatasourceImpl().currentUserId;

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(name: "Basics", priority: 1),
    CategoryModel(name: "Secondaries", priority: 2),
    CategoryModel(name: "Expenses", priority: 3),
    CategoryModel(name: "Savings", priority: 4),
  ].obs;
  RxDouble monthlyAndWalletExpense = 0.0.obs;
  final mainController = Get.find<MainController>();

  var walletsListController = Get.find<WalletsListController>();

  @override
  void onInit() {
    super.onInit();
    everAll([dashboardMonth, mainController.selectWallet], (_) {
      calculateTotals();
    });
    calculateTotals();
    scrollController.addListener(_scrollListener);
    fetchExpenses(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMoreData.value) {
        print(
          "🔗 Scroll reaching end: Requesting Expenses page ${currentPage.value}",
        );
        fetchExpenses(isRefresh: false);
      }
    }
  }

  Future<void> fetchExpenses({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMoreData.value && !isRefresh)) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        print("🔄 Action: Refreshing Expenses list...");
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      print("📡 Fetching Expenses: Page ${currentPage.value}, Size $pageSize");
      final result = await getExpensesUseCase.call(
        userId,
        PageRequest(pageNumber: currentPage.value, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          print("❌ Expenses Fetch Failure: ${failure.message}");
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;
          print("📦 Received: ${newItems.length} Expenses");
          newItems
              .map(
                (e) => e.wallet = walletsListController.wallets.firstWhere(
                  (w) => w.walletId == e.walletId,
                ),
              )
              .toList();
          if (newItems.isEmpty) {
            hasMoreData.value = false;
            print("🏁 No more Expenses found on server.");
          } else {
            if (isRefresh) {
              // تصفية العناصر المحذوفة محلياً قبل العرض
              final visibleItems = newItems
                  .where((e) => e.localId != "REMOVE")
                  .toList();
              expensesList.assignAll(visibleItems.reversed);
            } else {
              // منع التكرار وتصفية المحذوفات
              final uniqueAndVisible = newItems.where((newItem) {
                bool isNotRemoved = newItem.localId != "REMOVE";
                bool isNotDuplicate = !expensesList.any(
                  (existing) =>
                      (existing.id != null && existing.id == newItem.id) ||
                      (existing.localId == newItem.localId),
                );
                return isNotRemoved && isNotDuplicate;
              }).toList();

              expensesList.assignAll(uniqueAndVisible.reversed);
              print(
                "➕ Added ${uniqueAndVisible.length} unique Expenses to list",
              );
            }

            // تحديث حالة انتهاء البيانات
            if (newItems.length < pageSize) {
              hasMoreData.value = false;
              print("🏁 End of Expenses reached.");
            } else {
              currentPage.value++;
            }
          }
          calculateTotals();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void runBackgroundSync() {
    syncExpenseUsecase.call().then((result) {
      result.fold(
        (l) => print("⚠️ Expense Background Sync Failed: ${l.message}"),
        (r) {
          print("✅ Expense Background Sync Completed");
          calculateTotals();
        },
      );
    });
  }

  Future<void> calculateTotals() async {
    final result = await getAllLocalExpensesUsecase.call();
    result.fold(
      (_) {
        monthlyExpenseTotal.value = 0.0;
        allTimeExpenseTotal.value = 0.0;
      },
      (allLocalExpense) {
        final targetYear = dashboardMonth.value.year;
        final targetMonth = dashboardMonth.value.month;

        // تصفية العناصر المسمومة للحذف لضمان دقة الأرقام
        final activeExpenses = allLocalExpense
            .where((e) => e.localId != "REMOVE")
            .toList();

        double allTime = 0.0;
        double monthly = 0.0;

        for (var item in activeExpenses) {
          allTime += item.amount;
          if (item.date.year == targetYear && item.date.month == targetMonth) {
            monthly += item.amount;
          }
        }

        allTimeExpenseTotal.value = allTime;
        monthlyExpenseTotal.value = monthly;

        monthlyAndWalletExpense.value = activeExpenses
            .where(
              (e) =>
                  e.date.year == targetYear &&
                  e.date.month == targetMonth &&
                  e.wallet!.currency.currencyName ==
                      mainController.selectWallet.value?.currency.currencyName,
            )
            .fold<double>(0.0, (sum, item) => sum + item.amount);
      },
    );
  }

  void changeDashboardMonth(DateTime newDate) {
    print("📅 Changing Dashboard Month to: ${newDate.month}/${newDate.year}");
    dashboardMonth.value = DateTime(newDate.year, newDate.month, 1);
    calculateTotals();
  }

  @override
  void onClose() {
    print("🔌 Closing ExpensesListController");
    scrollController.dispose();
    super.onClose();
  }
}
