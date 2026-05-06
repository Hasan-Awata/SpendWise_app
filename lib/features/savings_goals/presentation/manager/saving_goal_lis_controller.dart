// // تعليق: متحكم عرض قائمة الأهداف - مسؤول عن جلب البيانات، التمرير اللانهائي، وحساب التقدم الإجمالي
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';

import 'package:spendwise/features/auth/data/datasource/app_user_local_datasource_impl.dart';
import 'package:spendwise/features/savings_goals/data/models/saving_goal_model.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/get_saving_goal_usecase.dart';

class SavingGoalListController extends GetxController {
  final GetSavingGoalsUseCase getSavingGoalsUseCase;

  SavingGoalListController({required this.getSavingGoalsUseCase});

  final savingGoals = <SavingGoalModel>[].obs;
  final isLoading = false.obs;
  final ScrollController scrollController = ScrollController();

  // إحصائيات سريعة
  final totalTargetAmount = 0.0.obs;
  final totalSavedAmount = 0.0.obs;

  int currentPage = 1;
  bool hasMore = true;
  final int pageSize = 15;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadSavingGoals(isRefresh: true);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      if (!isLoading.value && hasMore) {
        loadSavingGoals(isRefresh: false);
      }
    }
  }

  // // تعليق: جلب الأهداف من المستودع مع فحص التكرار لضمان دقة البيانات المعروضة
  Future<void> loadSavingGoals({bool isRefresh = false}) async {
    if (isLoading.value || (!hasMore && !isRefresh)) return;

    final uId = AppUserLocalDatasourceImpl().currentUserId;
    if (uId == null) return;

    try {
      isLoading.value = true;

      if (isRefresh) {
        currentPage = 1;
        hasMore = true;
      }

      final result = await getSavingGoalsUseCase.call(
        uId,
        PageRequest(pageNumber: currentPage, pageSize: pageSize),
      );

      result.fold(
        (failure) {
          HelperFunction.showSnackBar("تنبيه", failure.message, isError: true);
        },
        (pagedResponse) {
          final newItems = pagedResponse.data;

          if (isRefresh) {
            savingGoals.assignAll(newItems);
          } else {
            // منع التكرار بناءً على المعرف المحلي والسيرفر
            for (var newItem in newItems) {
              bool isDuplicate = savingGoals.any(
                (existing) =>
                    (newItem.goalId != null &&
                        existing.goalId == newItem.goalId) ||
                    (existing.localId == newItem.localId),
              );

              if (!isDuplicate) {
                savingGoals.add(newItem);
              }
            }
          }

          // تحديث حالة التمرير
          if (newItems.length < pageSize) {
            hasMore = false;
          } else {
            currentPage++;
          }

          _calculateSummary();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // // تعليق: حساب إجمالي المبالغ المستهدفة والموفرة للأهداف الحالية
  void _calculateSummary() {
    double target = 0;
    double saved = 0;
    for (var goal in savingGoals) {
      target += goal.targetAmount;
      saved += goal.currentAmount;
    }
    totalTargetAmount.value = target;
    totalSavedAmount.value = saved;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
