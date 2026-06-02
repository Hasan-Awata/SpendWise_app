import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/auth/domain/usecases/get_user_id_usecase.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/pages/domain/entities/page_request.dart';
import 'package:spendwise/features/savings_goals/data/datasources/saving_goal_local_datasource.dart';
import 'package:spendwise/features/savings_goals/domain/entities/saving_goal_entity.dart';
import 'package:spendwise/features/savings_goals/domain/usecases/get_saving_goal_usecase.dart';

// saving_goal_list_controller.dart

class SavingGoalListController extends GetxController {
  final GetSavingGoalsUseCase getSavingGoalsUseCase;
  final GetUserIdUsecase userIdUsecase;

  SavingGoalListController({
    required this.getSavingGoalsUseCase,
    required this.userIdUsecase,
  });

  // =========================
  // STATE
  // =========================
  final savingGoals = <SavingGoalEntity>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs; // لإضافة مؤشر تحديث علوي
  final isLoadingMore = false.obs;

  final ScrollController scrollController = ScrollController();

  final totalTargetAmount = 0.0.obs;
  final totalSavedAmount = 0.0.obs;

  int currentPage = 1;
  bool hasMore = true;
  final int pageSize = 15;

  // قفل داخلي لمنع تداخل العمليات (Race Condition)
  bool _isProcessing = false;
  int? _userId;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    loadSavingGoals(isRefresh: true);
  }

  // =========================
  // SCROLL LISTENER
  // =========================
  void _scrollListener() {
    if (!scrollController.hasClients || _isProcessing) return;

    final position = scrollController.position;
    // التحميل عند الوصول لـ 85% من نهاية القائمة لتجربة مستخدم أسلس
    if (position.pixels >= position.maxScrollExtent * 0.85) {
      if (hasMore && !isLoadingMore.value && !isLoading.value) {
        loadSavingGoals(isRefresh: false);
      }
    }
  }

  // =========================
  // USER ID HELPER
  // =========================
  Future<int?> _getUserId() async {
    if (_userId != null) return _userId;

    final result = await userIdUsecase.getUserId();
    result.fold(
      (failure) =>
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
      (id) => _userId = id,
    );
    return _userId;
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> loadSavingGoals({bool isRefresh = false}) async {
    if (_isProcessing) return;

    final userId = await _getUserId();
    if (userId == null) return;

    _isProcessing = true;
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage = 1;
        hasMore = true;
      } else {
        isLoadingMore.value = true;
      }

      // إظهار اللودر الرئيسي فقط في أول مرة
      if (savingGoals.isEmpty && isRefresh) isLoading.value = true;

      final result = await getSavingGoalsUseCase.call(
        userId,
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
            _mergeNewItems(newItems);
          }

          // ترتيب الأهداف (الأحدث أولاً)
          savingGoals.sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );

          // تحديث حالة الصفحات
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
      isRefreshing.value = false;
      isLoadingMore.value = false;
      _isProcessing = false;
    }
  }

  // دالة الدمج مع منع التكرار بكفاءة (O(n) باستخدام Set)
  void _mergeNewItems(List<SavingGoalEntity> newItems) {
    final existingLocalIds = savingGoals.map((e) => e.localId).toSet();
    final existingRemoteIds = savingGoals
        .where((e) => e.goalId != null)
        .map((e) => e.goalId)
        .toSet();

    final List<SavingGoalEntity> filteredNewItems = newItems.where((item) {
      final isDuplicateLocal = existingLocalIds.contains(item.localId);
      final isDuplicateRemote =
          item.goalId != null && existingRemoteIds.contains(item.goalId);
      return !isDuplicateLocal && !isDuplicateRemote;
    }).toList();

    if (filteredNewItems.isNotEmpty) {
      savingGoals.addAll(filteredNewItems);
    }
  }

  // =========================
  // SUMMARY CALCULATIONS
  // =========================
  void _calculateSummary() {
    double target = 0;
    double saved = 0;

    for (final g in savingGoals) {
      // نتجاهل الأهداف المحذوفة من الحسابات الإجمالية
      if (g.isDeleted) continue;
      target += g.targetAmount;
      saved += g.currentAmount;
    }

    totalTargetAmount.value = target;
    totalSavedAmount.value = saved;
  }

  // =========================
  // UI HELPERS
  // =========================
  Future<void> refreshData() => loadSavingGoals(isRefresh: true);

  void addGoalLocally(SavingGoalEntity goal) {
    savingGoals.insert(0, goal);
    _calculateSummary();
  }

  void updateGoalLocally(SavingGoalEntity updatedGoal) {
    final index = savingGoals.indexWhere(
      (e) => e.localId == updatedGoal.localId,
    );
    if (index != -1) {
      // تحديث البيانات مع الحفاظ على حالة الـ localId
      savingGoals[index] = updatedGoal;
      savingGoals.refresh();
      _calculateSummary();
    }
  }

  // دالة متخصصة للتعامل مع المزامنة (تُستدعى من الـ ActionController)
  void notifyGoalChanged(String localId) async {
    // إعادة تحميل البيانات أو تحديث العنصر المتأثر فقط من الـ LocalDatasource
    final updated = await Get.find<SavingGoalLocalDataSource>().getSavingGoal(
      localId,
    );
    if (updated != null) {
      updateGoalLocally(updated.toEntity());
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
