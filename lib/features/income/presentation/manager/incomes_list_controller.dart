// incomes_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/expense/presentation/manager/expense_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/home/presentation/manager/main_controller.dart';
import 'package:spendwise/features/income/domain/entities/income_entity.dart';
import 'package:spendwise/features/income/domain/usecases/get_all_local_incomes_usecase.dart';
import 'package:spendwise/features/income/domain/usecases/get_incomes_usecase.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

class IncomesListController extends GetxController {
  final GetIncomesUsecase getIncomesUseCase;
  final GetAllLocalIncomesUsecase getAllLocalIncomesUsecase;
  final GetUserIdUsecase userIdUsecase;

  IncomesListController({
    required this.getIncomesUseCase,
    required this.getAllLocalIncomesUsecase,
    required this.userIdUsecase,
  });

  final RxList<IncomeEntity> incomesList = <IncomeEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 10;

  bool _isProcessing = false;

  final mainController = Get.find<MainController>();
  final Rx<DateTime> dashboardMonth = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );

  final RxDouble monthlyIncomeTotal = 0.0.obs;
  final RxDouble allTimeIncomeTotal = 0.0.obs;
  final RxDouble monthlyAndWalletIncome = 0.0.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    everAll([
      dashboardMonth,
      mainController.selectWallet,
    ], (_) => calculateTotals());
    calculateTotals();
    scrollController.addListener(_scrollListener);
    fetchAllIncomes(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 100) {
      if (!isLoading.value && hasMoreData.value) {
        fetchAllIncomes(isRefresh: false);
      }
    }
  }

  Future<void> fetchAllIncomes({bool isRefresh = false}) async {
    if (_isProcessing) return;
    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing = true;
    try {
      isLoading.value = true;
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      int? userId;
      final resultUserId = await userIdUsecase.getUserId();
      resultUserId.fold((l) => null, (id) => userId = id);

      final result = await getIncomesUseCase.call(
        userId,
        PageRequest(pageNumber: currentPage.value, pageSize: pageSize),
      );

      await result.fold(
        (failure) async {
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true);
        },
        (pagedResponse) async {
          final fetchedItems = pagedResponse.data;

          // 🔥 تنظيف التكرار من التخزين المحلي قبل عرض البيانات
          await _cleanupDuplicateLocals(fetchedItems);

          if (isRefresh) {
            incomesList.assignAll(fetchedItems);
          } else {
            // إضافة العناصر الفريدة فقط للذاكرة
            final existingIds = incomesList.map((e) => e.localId).toSet();
            final uniqueItems = fetchedItems
                .where((item) => !existingIds.contains(item.localId))
                .toList();
            incomesList.addAll(uniqueItems);
          }

          incomesList.sort((a, b) => b.date.compareTo(a.date));

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
      _isProcessing = false;
    }
  }

  /// دالة لفحص وحذف التكرار من التخزين المحلي (Isar/Hive)
  Future<void> _cleanupDuplicateLocals(List<IncomeEntity> remoteItems) async {
    final localResult = await getAllLocalIncomesUsecase.call();

    await localResult.fold((_) async {}, (allLocal) async {
      for (var remoteItem in remoteItems) {
        if (remoteItem.id == null) continue;

        // البحث عن أي عنصر محلي يمتلك نفس ID السيرفر ولكن بـ localId مختلف
        final duplicates = allLocal
            .where(
              (local) =>
                  local.id == remoteItem.id &&
                  local.localId != remoteItem.localId,
            )
            .toList();

        for (var dup in duplicates) {
          // حذف التكرار من القائمة المعروضة
          incomesList.removeWhere((e) => e.localId == dup.localId);

          // 🔥 هنا يجب استدعاء دالة الحذف الفعلية من الـ Repository/Local DataSource
          // سنفترض وجود دالة تؤدي الغرض (يجب التأكد من توفرها في الـ UseCase الخاص بك)
          // await deleteIncomeFromLocal(dup.localId);

          debugPrint("🔥 Duplicate Income deleted locally: ${dup.localId}");
        }
      }
    });
  }

  Future<void> calculateTotals() async {
    final result = await getAllLocalIncomesUsecase.call();
    result.fold((_) {}, (allLocalIncomes) {
      final year = dashboardMonth.value.year;
      final month = dashboardMonth.value.month;
      final active = allLocalIncomes.where((i) => i.isDeleted != true).toList();

      allTimeIncomeTotal.value = active.fold(0.0, (s, e) => s + e.amount);
      monthlyIncomeTotal.value = active
          .where((i) => i.date.year == year && i.date.month == month)
          .fold(0.0, (s, e) => s + e.amount);

      monthlyAndWalletIncome.value = active
          .where(
            (i) =>
                i.date.year == year &&
                i.date.month == month &&
                i.wallet?.currency.currencyName ==
                    mainController.selectWallet.value?.currency.currencyName,
          )
          .fold(0.0, (s, e) => s + e.amount);
    });
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

      calculateTotals();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
