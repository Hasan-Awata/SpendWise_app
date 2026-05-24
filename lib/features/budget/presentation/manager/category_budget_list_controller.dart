// category_budget_list_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/domain/usecases/get_category_budget_usecase.dart';

class CategoryBudgetListController extends GetxController {
  final GetAllCategoryBudgetsUseCase getBudgetsUseCase;

  CategoryBudgetListController({required this.getBudgetsUseCase});

  final budgets = <CategoryBudgetEntity>[].obs;
  final isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool _isProcessing = false.obs;
  final errorMessage = RxnString();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadBudgets(isRefresh: true);
  }

  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing.value) return;

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 100) {
      if (!isLoadingMore.value && !isLoading.value && hasMoreData.value) {
        loadBudgets();
      }
    }
  }

  Future<void> loadBudgets({bool isRefresh = false}) async {
    if (_isProcessing.value) return;
    if (!isRefresh && !hasMoreData.value) return;

    _isProcessing.value = true;
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }
      if (budgets.isEmpty && isRefresh) {
        isLoading.value = true;
      }

      final result = await getBudgetsUseCase.call();

      result.fold(
        (failure) {
          errorMessage.value = _mapFailure(failure);
        },
        (data) {
          budgets.assignAll(data);
          budgets.sort((a, b) => b.startDate.compareTo(a.startDate));

          // الميزانيات غالباً لا تدعم Pagination حقيقي على مستوى الفئات، لذا نغلقها إذا كان العائد كاملاً
          if (data.length < 10) {
            hasMoreData.value = false;
          }
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      // تم تعديل الـ finally لتصفير كافة المؤشرات لكي لا تعلق دوائر الانتظار بالواجهة
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing.value = false;
    }
  }

  String _mapFailure(Failure failure) {
    return failure.message;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
