import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/domain/usecases/update_category_budget_usecase.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class CategoryWithBudget {
  final int categoryId;
  final String name;
  CategoryBudgetEntity? budget;

  CategoryWithBudget({
    required this.categoryId,
    required this.name,
    this.budget,
  });
}

class ManageCategoryBudgetController extends GetxController {
  final UpdateCategoryBudgetUsecase updateBudgetUseCase;

  ManageCategoryBudgetController({required this.updateBudgetUseCase});

  final CategoryBudgetListController listController =
      Get.find<CategoryBudgetListController>();

  final formKey = GlobalKey<FormState>();
  final percentageController = TextEditingController();

  var isLoading = false.obs;
  var selectedCategoryId = 1.obs;
  var isActive = true.obs;
  var sliderValue = 25.0.obs;
  var hasUnsavedChanges = false.obs;

  var startDate = Rxn<DateTime>(DateTime.now());
  var endDate = Rxn<DateTime>(DateTime.now().add(const Duration(days: 15)));

  final List<CategoryWithBudget> categoryList = [
    CategoryWithBudget(categoryId: 1, name: "Essentials"),
    CategoryWithBudget(categoryId: 2, name: "Secondaries"),
    CategoryWithBudget(categoryId: 3, name: "Luxuries"),
    CategoryWithBudget(categoryId: 4, name: "Savings"),
  ];

  RxList<CategoryBudgetEntity> get activeBudgets => listController.budgets;
  bool _isOptimisticUpdating = false;

  @override
  void onInit() {
    super.onInit();

    _bindBudgetsFromListController();

    ever(listController.budgets, (_) {
      if (!_isOptimisticUpdating) {
        _bindBudgetsFromListController();
      }
    });

    ever(selectedCategoryId, (_) => updateFieldsForSelectedCategory());

    ever(sliderValue, (_) => _checkIfDataChanged());
    ever(isActive, (_) => _checkIfDataChanged());
    ever(startDate, (_) => _checkIfDataChanged());
    ever(endDate, (_) => _checkIfDataChanged());
  }

  void _bindBudgetsFromListController() {
    for (var cat in categoryList) {
      final found = listController.budgets.firstWhereOrNull(
        (b) => b.categoryId == cat.categoryId,
      );
      cat.budget = found;
    }
    updateFieldsForSelectedCategory();
  }

  void updateFieldsForSelectedCategory() {
    final currentCat = categoryList.firstWhere(
      (c) => c.categoryId == selectedCategoryId.value,
    );

    if (currentCat.budget != null) {
      sliderValue.value = currentCat.budget!.percentageLimit;
      percentageController.text = currentCat.budget!.percentageLimit
          .toStringAsFixed(0);
      startDate.value = currentCat.budget!.startDate;
      endDate.value = currentCat.budget!.endDate;
      isActive.value = currentCat.budget!.isActive;
    } else {
      sliderValue.value = 25.0;
      percentageController.text = "25";
      startDate.value = DateTime.now();
      endDate.value = DateTime.now().add(const Duration(days: 15));
      isActive.value = true;
    }
    hasUnsavedChanges.value = false;
  }

  void _checkIfDataChanged() {
    final currentCat = categoryList.firstWhere(
      (c) => c.categoryId == selectedCategoryId.value,
    );

    if (currentCat.budget != null) {
      final isSliderChanged =
          sliderValue.value.toStringAsFixed(0) !=
          currentCat.budget!.percentageLimit.toStringAsFixed(0);
      final isStatusChanged = isActive.value != currentCat.budget!.isActive;

      final isStartDateChanged =
          startDate.value?.year != currentCat.budget!.startDate.year ||
          startDate.value?.month != currentCat.budget!.startDate.month ||
          startDate.value?.day != currentCat.budget!.startDate.day;

      final isEndDateChanged =
          endDate.value?.year != currentCat.budget!.endDate.year ||
          endDate.value?.month != currentCat.budget!.endDate.month ||
          endDate.value?.day != currentCat.budget!.endDate.day;

      hasUnsavedChanges.value =
          isSliderChanged ||
          isStatusChanged ||
          isStartDateChanged ||
          isEndDateChanged;
    } else {
      hasUnsavedChanges.value = sliderValue.value != 25.0 || !isActive.value;
    }
  }

  Future<void> saveOrUpdateBudget(int userId, double currentSliderValue) async {
    if (!hasUnsavedChanges.value) {
      HelperFunction.showSnackBar(
        "خطأ",
        "يرجى ادخال بيانات ليتم التعديل",
        isError: true,
      );
      return;
    }
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final currentCat = categoryList.firstWhere(
      (c) => c.categoryId == selectedCategoryId.value,
    );

    final roundedPercentage = double.parse(
      currentSliderValue.toStringAsFixed(2),
    );
    final hasExistingBudget = currentCat.budget != null;
    final existingBudget = currentCat.budget;

    final CategoryBudgetEntity updatedEntity = CategoryBudgetEntity(
      localId: hasExistingBudget ? existingBudget!.localId : "",
      categoryBudgetId: hasExistingBudget
          ? existingBudget!.categoryBudgetId
          : -1,
      userId: userId,
      categoryId: currentCat.categoryId,
      percentageLimit: roundedPercentage,
      startDate: startDate.value!,
      endDate: endDate.value!,
      isActive: isActive.value,
      isSynced: false.obs,
      isDeleted: false,
      percentageProgress: hasExistingBudget
          ? existingBudget!.percentageProgress
          : 0.0,
      moneyLimit: hasExistingBudget ? existingBudget!.moneyLimit : 0.0,
      spendingProgress: hasExistingBudget
          ? existingBudget!.spendingProgress
          : 0.0,
    );

    print(
      "📡 Sending Update/Upsert Request for Category ID: ${currentCat.categoryId}",
    );

    final result = await updateBudgetUseCase.call(updatedEntity);

    result.fold(
      (failure) =>
          HelperFunction.showSnackBar("خطأ", failure.message, isError: true),
      (_) {
        HelperFunction.showSnackBar(
          "نجاح",
          "تم حفظ وتحديث ميزانية الفئة بنجاح",
        );

        _isOptimisticUpdating = true;

        currentCat.budget = updatedEntity;
        updateFieldsForSelectedCategory();
        hasUnsavedChanges.value = false;

        final targetIndex = listController.budgets.indexWhere(
          (b) => b.categoryId == updatedEntity.categoryId,
        );
        if (targetIndex != -1) {
          listController.budgets[targetIndex] = updatedEntity;
        } else {
          listController.budgets.add(updatedEntity);
        }
        listController.budgets.refresh();

        listController.loadBudgets(isRefresh: true).then((_) {
          _isOptimisticUpdating = false;
        });
      },
    );

    isLoading.value = false;
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      startDate.value = picked;
      _checkIfDataChanged();
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      endDate.value = picked;
      _checkIfDataChanged();
    }
  }
}
