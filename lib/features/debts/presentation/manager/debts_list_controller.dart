import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/debts/domain/entities/shared_debt_entity.dart';
import 'package:spendwise/features/debts/domain/usecases/get_debts_usecase.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class DebtsListController extends GetxController {
  final GetDebtsUseCase getDebtsUseCase;

  final GetUserIdUsecase userIdUsecase;

  DebtsListController({
    required this.getDebtsUseCase,
    required this.userIdUsecase,
  });

  final RxList<SharedDebtEntity> debts = <SharedDebtEntity>[].obs;

  final RxBool isLoading = false.obs;

  final RxBool hasMoreData = true.obs;

  final RxInt currentPage = 1.obs;

  final int pageSize = 10;

  final RxBool isLoadingMore = false.obs;

  final RxBool isRefreshing = false.obs;

  final RxString errorMessage = ''.obs;

  bool _isProcessing = false;

  final ScrollController scrollController = ScrollController();

  final mainController = Get.find<MainController>();

  // ==========================================
  // Dashboard
  // ==========================================

  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble totalDebts = 0.0.obs;

  final RxDouble monthlyDebts = 0.0.obs;

  final RxDouble pendingDebts = 0.0.obs;

  final RxDouble paidDebts = 0.0.obs;

  // ==========================================
  // INIT
  // ==========================================

  @override
  void onInit() {
    super.onInit();

    ever(dashboardMonth, (_) => updateDashboardTotals());

    scrollController.addListener(_scrollListener);

    fetchAllDebts(isRefresh: true);
  }

  // ==========================================
  // SCROLL
  // ==========================================

  void _scrollListener() {
    if (!scrollController.hasClients) {
      return;
    }

    if (_isProcessing) {
      return;
    }

    if (!hasMoreData.value) {
      return;
    }

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 120) {
      if (!isLoading.value && !isLoadingMore.value) {
        fetchAllDebts();
      }
    }
  }

  // ==========================================
  // FETCH
  // ==========================================

  Future<void> fetchAllDebts({bool isRefresh = false}) async {
    if (_isProcessing) {
      return;
    }

    if (!isRefresh && !hasMoreData.value) {
      return;
    }

    _isProcessing = true;

    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        isRefreshing.value = true;
      } else {
        isLoadingMore.value = true;
      }

      if (debts.isEmpty && isRefresh) {
        isLoading.value = true;
      }

      int? userId;

      final userResult = await userIdUsecase.getUserId();

      userResult.fold((_) {}, (id) => userId = id);

      final result = await getDebtsUseCase.call(
        userId,
        PageRequest(pageNumber: currentPage.value, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (pagedResponse) {
          final fetched = pagedResponse;

          if (isRefresh) {
            debts.assignAll(fetched);
          } else {
            final existingIds = debts.map((e) => e.localId).toSet();

            final uniqueItems = fetched.where(
              (e) => !existingIds.contains(e.localId),
            );

            debts.addAll(uniqueItems);
          }

          debts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (fetched.length < pageSize) {
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

  // ==========================================
  // TOTALS
  // ==========================================

  void updateDashboardTotals() {
    final year = dashboardMonth.value.year;
    final month = dashboardMonth.value.month;

    final validDebts = debts.whereType<SharedDebtEntity>().toList();

    totalDebts.value = validDebts.fold(0.0, (sum, debt) => sum + debt.amount);

    monthlyDebts.value = validDebts
        .where((d) => d.createdAt.year == year && d.createdAt.month == month)
        .fold(0.0, (sum, debt) => sum + debt.amount);

    pendingDebts.value = validDebts
        .where((d) => d.status.toLowerCase() == "pending")
        .fold(0.0, (sum, debt) => sum + debt.amount);

    paidDebts.value = validDebts
        .where((d) => d.status.toLowerCase() == "paid")
        .fold(0.0, (sum, debt) => sum + debt.amount);
  }

  // ==========================================
  // MONTH PICKER
  // ==========================================

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
    }
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
