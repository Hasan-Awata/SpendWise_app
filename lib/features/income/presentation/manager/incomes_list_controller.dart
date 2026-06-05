// incomes_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/wallet/presentation/manager/wallets_list_controller.dart';

class IncomesListController extends GetxController {
  final GetIncomesUsecase getIncomesUseCase;
  final GetUserIdUsecase userIdUsecase;

  IncomesListController({
    required this.getIncomesUseCase,
    required this.userIdUsecase,
  });

  final RxList<IncomeEntity> incomesList = <IncomeEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;
  final RxBool isLoadingMore = false.obs;
  bool _isProcessing = false;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;

  final mainController = Get.find<MainController>();
  final ScrollController scrollController = ScrollController();

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyIncomeTotal = 0.0.obs;
  final RxDouble allTimeIncomeTotal = 0.0.obs;
  final RxDouble monthlyAndWalletIncome = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // مراقبة تغيير الشهر أو المحفظة لتحديث الإجماليات

    ever(
      Get.find<WalletsListController>().wallets,
      (_) => fetchAllIncomes(isRefresh: true),
    );
    everAll([
      dashboardMonth,
      mainController.selectWallet,
    ], (_) => updateDashboardTotals());

    scrollController.addListener(_scrollListener);

    fetchAllIncomes(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;
    if (!hasMoreData.value) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      if (!isLoading.value && !isLoadingMore.value) {
        fetchAllIncomes();
      }
    }
  }

  /// جلب البيانات (تعتمد الآن على الـ Repository للتعامل مع الـ Sync والـ Duplicates)
  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    if (_isProcessing) return;
    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing = true;
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      // إظهار اللودر في أول عملية جلب فقط
      if (incomesList.isEmpty && isRefresh) isLoading.value = true;

      int? userId;
      final resultUserId = await userIdUsecase.getUserId();
      resultUserId.fold((l) => null, (id) => userId = id);

      final result = await getIncomesUseCase.call(
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
            incomesList.assignAll(fetchedItems);
          } else {
            // دمج العناصر الجديدة مع التأكد من عدم تكرار الـ localId
            final existingIds = incomesList.map((e) => e.localId).toSet();
            final uniqueNewItems = fetchedItems.where(
              (item) => !existingIds.contains(item.localId),
            );
            incomesList.addAll(uniqueNewItems);
          }

          // الترتيب حسب التاريخ (الأحدث أولاً)
          incomesList.sort((a, b) => b.date.compareTo(a.date));

          // تحديث حالة الـ Pagination
          if (fetchedItems.length < pageSize) {
            hasMoreData.value = false;
          } else {
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
      _isProcessing = false;
    }
  }

  /// تم تبسيط هذه الدالة لتعمل على القائمة الموجودة في الذاكرة حالياً
  void updateDashboardTotals() {
    final year = dashboardMonth.value.year;
    final month = dashboardMonth.value.month;

    // إجمالي كل الأوقات (من البيانات المحملة حالياً)
    allTimeIncomeTotal.value = incomesList.fold(0.0, (s, e) => s + e.amount);

    // إجمالي الشهر المختار
    monthlyIncomeTotal.value = incomesList
        .where((i) => i.date.year == year && i.date.month == month)
        .fold(0.0, (s, e) => s + e.amount);

    // إجمالي الشهر المختار + المحفظة المختارة
    monthlyAndWalletIncome.value = incomesList
        .where((i) {
          final isSameMonth = i.date.year == year && i.date.month == month;
          final isSameWallet =
              i.wallet?.currency.currencyName ==
              mainController.selectWallet.value?.currency.currencyName;
          return isSameMonth && isSameWallet;
        })
        .fold(0.0, (s, e) => s + e.amount);
  }

  Future<void> pickDashboardMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dashboardMonth.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "اختر الشهر",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: SpColor.accentBlue,
              surface: SpColor.surfaceNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dashboardMonth.value = DateTime(picked.year, picked.month, 1);

      if (Get.isRegistered<ExpensesListController>()) {
        Get.find<ExpensesListController>().dashboardMonth.value =
            dashboardMonth.value;
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
