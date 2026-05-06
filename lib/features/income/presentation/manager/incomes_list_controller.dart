import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/get_all_local_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/synced_income_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class IncomesListController extends GetxController {
  final GetIncomesUsecase getIncomesUseCase;
  final GetAllLocalIncomesUsecase getAllLocalIncomesUsecase;
  final SyncPendingIncomesUsecase syncIncomesUsecase;

  IncomesListController({
    required this.getIncomesUseCase,
    required this.getAllLocalIncomesUsecase,
    required this.syncIncomesUsecase,
  });

  final RxList<IncomeModel> incomesList = <IncomeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;
  final mainController = Get.find<MainController>();
  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyIncomeTotal = 0.0.obs;
  final RxDouble allTimeIncomeTotal = 0.0.obs;
  final RxDouble monthlyAndWalletIncome = 0.0.obs;

  final ScrollController scrollController = ScrollController();
  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  var walletsListController = Get.find<WalletsListController>();

  @override
  void onInit() {
    super.onInit();
    everAll([dashboardMonth, mainController.selectWallet], (_) {
      calculateTotals();
    });
    calculateTotals();
    scrollController.addListener(_scrollListener);
    fetchAllIncomes(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMoreData.value) {
        print(
          "🔗 Scroll reaching end: Requesting Incomes page ${currentPage.value}",
        );
        fetchAllIncomes(isRefresh: false);
      }
    }
  }

  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMoreData.value && !isRefresh)) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        print("🔄 Action: Refreshing Incomes list...");
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      print("📡 Fetching Incomes: Page ${currentPage.value}, Size $pageSize");
      final pageRequest = PageRequest(
        pageNumber: currentPage.value,
        pageSize: pageSize,
      );
      final result = await getIncomesUseCase.call(userId, pageRequest);

      result.fold(
        (failure) {
          print("❌ Incomes Fetch Failure: ${failure.message}");
          _handleError("خطأ في التحميل", failure.message);
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;
          print("📦 Received: ${newItems.length} Incomes");

          // newItems
          //     .map(
          //       (i) => i.wallet = walletsListController.wallets.firstWhere(
          //         (w) => w.walletId == i.walletId,
          //       ),
          //     )
          //     .toList();
          if (newItems.isEmpty) {
            hasMoreData.value = false;
            print("🏁 No more Incomes found on server.");
          } else {
            if (isRefresh) {
              // تصفية المحذوفات محلياً قبل العرض
              final visibleItems = newItems
                  .where((i) => i.localId != "REMOVE")
                  .toList();
              incomesList.assignAll(visibleItems.reversed);
            } else {
              // // Logic: الإضافة في نهاية القائمة مع تصفية المكرر والمحذوف
              final uniqueAndVisible = newItems.where((newItem) {
                bool isNotRemoved = newItem.localId != "REMOVE";
                bool isNotDuplicate = !incomesList.any(
                  (existing) =>
                      (existing.id != null && existing.id == newItem.id) ||
                      (existing.localId == newItem.localId),
                );
                return isNotRemoved && isNotDuplicate;
              }).toList();

              incomesList.assignAll(uniqueAndVisible.reversed);
              print(
                "➕ Added ${uniqueAndVisible.length} unique Incomes to list",
              );
            }

            if (newItems.length < pageSize) {
              hasMoreData.value = false;
              print("🏁 End of Incomes reached (Last page).");
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
    syncIncomesUsecase.call().then((result) {
      result.fold(
        (l) => print("⚠️ Incomes Background Sync Failed: ${l.message}"),
        (r) {
          print("✅ Incomes Background Sync Completed");
          calculateTotals(); // إعادة حساب الإجماليات بعد المزامنة
        },
      );
    });
  }

  Future<void> calculateTotals() async {
    final result = await getAllLocalIncomesUsecase.call();

    result.fold((failure) => print("❌ Failed to calculate totals from local"), (
      allLocalIncomes,
    ) {
      final targetYear = dashboardMonth.value.year;
      final targetMonth = dashboardMonth.value.month;

      // حساب الإجمالي التراكمي (باستثناء المعلم للحذف)
      final activeIncomes = allLocalIncomes
          .where((i) => i.localId != "REMOVE")
          .toList();

      allTimeIncomeTotal.value = activeIncomes.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );

      // حساب إجمالي الشهر المحدد
      monthlyIncomeTotal.value = activeIncomes
          .where(
            (i) => i.date.year == targetYear && i.date.month == targetMonth,
          )
          .fold<double>(0.0, (sum, item) => sum + item.amount);

      monthlyAndWalletIncome.value = activeIncomes
          .where(
            (i) =>
                i.date.year == targetYear &&
                i.date.month == targetMonth &&
                i.wallet?.currency.currencyName ==
                    mainController.selectWallet.value?.currency.currencyName,
          )
          .fold<double>(0.0, (sum, item) => sum + item.amount);
    });
  }

  Future<void> pickDashboardMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dashboardMonth.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "اختر شهر الإحصائيات",
      // إضافة التنسيق هنا
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: SpColor.accentBlue,
              onPrimary: Colors.white,
              surface: SpColor.surfaceNavy,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: SpColor.accentBlue),
            ),
            dialogTheme: DialogThemeData(backgroundColor: SpColor.surfaceNavy),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dashboardMonth.value = DateTime(picked.year, picked.month, 1);

      if (Get.isRegistered<ExpensesListController>()) {
        final expController = Get.find<ExpensesListController>();
        expController.dashboardMonth.value = dashboardMonth.value;
        expController.calculateTotals();
      }

      await calculateTotals();
    }
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  @override
  void onClose() {
    print("🔌 Closing IncomesListController");
    scrollController.dispose();
    super.onClose();
  }
}
