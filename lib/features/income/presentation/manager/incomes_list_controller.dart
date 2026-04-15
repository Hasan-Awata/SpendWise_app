// // تعليق: جلب الدخل مع التصفح + إحصائيات الشهر للوحة الرئيسية
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/income/domain/usecases/get_all_local_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomesListController extends GetxController {
  IncomesListController({
    required this.getIncomesUseCase,
    required this.getAllLocalIncomesUsecase,
  });

  final GetIncomesUsecase getIncomesUseCase;
  final GetAllLocalIncomesUsecase getAllLocalIncomesUsecase;

  final RxList<IncomeModel> incomesList = <IncomeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );
  final RxDouble monthlyIncomeTotal = 0.0.obs;

  final ScrollController scrollController = ScrollController();
  int? userId = AppUserLocalDatasourceImpl().currentUserId;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchAllIncomes();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      fetchAllIncomes();
    }
  }

  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (isLoading.value && !isRefresh)) return;

    isLoading.value = true;
    final pageRequest = PageRequest(
      pageNumber: currentPage.value,
      pageSize: 10,
    );

    final result = await getIncomesUseCase.call(userId, pageRequest);

    result.fold((failure) => _handleError("خطأ في التحميل", failure.message), (
      pagedResponse,
    ) {
      if (isRefresh) incomesList.clear();

      incomesList.addAll(pagedResponse.data);

      if (currentPage.value >= pagedResponse.totalPages) {
        hasMoreData.value = false;
      } else {
        currentPage.value++;
      }
    });

    isLoading.value = false;
    refreshMonthlyIncomeTotal();
  }

  Future<void> refreshMonthlyIncomeTotal() async {
    final result = await getAllLocalIncomesUsecase.call();
    result.fold((_) => monthlyIncomeTotal.value = 0.0, (all) {
      final year = dashboardMonth.value.year;
      final month = dashboardMonth.value.month;
      monthlyIncomeTotal.value = all
          .where((e) => e.date.year == year && e.date.month == month)
          .fold<double>(0, (sum, e) => sum + e.amount);
    });
  }

  Future<void> pickDashboardMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dashboardMonth.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dashboardMonth.value = DateTime(picked.year, picked.month, 1);
      await refreshMonthlyIncomeTotal();
    }
  }

  void _handleError(String title, String message) {
    HelperFunction.showSnackBar(title, message, isError: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
