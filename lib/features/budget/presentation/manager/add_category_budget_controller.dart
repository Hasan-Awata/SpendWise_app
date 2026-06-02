import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/domain/usecases/add_category_budget_usecase.dart'; // تأكد من إضافة هذا
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
  // إضافة الـ UseCase الخاص بالإضافة
  final AddCategoryBudgetUseCase? addBudgetUseCase;

  ManageCategoryBudgetController({
    required this.updateBudgetUseCase,
    this.addBudgetUseCase,
  });

  final CategoryBudgetListController listController =
      Get.find<CategoryBudgetListController>();

  // الـ Controller الخاص بـ TextField (مهم للـ UI)
  final TextEditingController percentageController = TextEditingController();

  final RxList<CategoryWithBudget> categoryList = <CategoryWithBudget>[
    CategoryWithBudget(categoryId: 1, name: "Essentials"),
    CategoryWithBudget(categoryId: 2, name: "Secondaries"),
    CategoryWithBudget(categoryId: 3, name: "Luxuries"),
    CategoryWithBudget(categoryId: 4, name: "Savings"),
  ].obs;

  final RxInt selectedCategoryId = 1.obs;
  final RxDouble sliderValue = 25.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isActive = true.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>(DateTime.now());
  final Rxn<DateTime> endDate = Rxn<DateTime>(
    DateTime.now().add(const Duration(days: 30)),
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isOverLimit = false.obs;

  void _updateLimitFlag() {
    isOverLimit.value = totalPercentage > 100.01;
  }

  @override
  void onInit() {
    super.onInit();

    // 1. التزامن الفوري في حال كانت البيانات موجودة مسبقاً
    if (!listController.isLoading.value) {
      _syncDataFromServer();
      _loadSelectedCategoryData();
    }

    // 2. الاستماع للتغييرات المستقبلية
    ever(listController.isLoading, (bool loading) {
      if (!loading) {
        _syncDataFromServer();
        _loadSelectedCategoryData();
      }
    });

    ever(selectedCategoryId, (_) => _loadSelectedCategoryData());
    ever(sliderValue, (_) => _updateLimitFlag());
  }

  void _syncDataFromServer() {
    for (var cat in categoryList) {
      cat.budget = listController.budgets.firstWhereOrNull(
        (b) => b.categoryId == cat.categoryId,
      );
    }
    categoryList.refresh();
  }

  double get totalPercentage {
    return categoryList.fold(0.0, (sum, item) {
      // إذا كان العنصر الحالي هو الذي نعدله، نأخذ القيمة من sliderValue، وإلا نأخذ القديم
      if (item.categoryId == selectedCategoryId.value)
        return sum + sliderValue.value;
      return sum + (item.budget?.percentageLimit ?? 0.0);
    });
  }

  // أضف هذا الـ Getter داخل الـ Controller
  CategoryWithBudget get selectedCategory {
    return categoryList.firstWhere(
      (c) => c.categoryId == selectedCategoryId.value,
      orElse: () => categoryList.first,
    );
  }

  bool get hasChanged {
    final cat = selectedCategory;
    if (cat.budget == null) return true; // إضافة جديدة دائماً تعتبر تغييراً

    return sliderValue.value != cat.budget!.percentageLimit ||
        isActive.value != cat.budget!.isActive ||
        startDate.value != cat.budget!.startDate ||
        endDate.value != cat.budget!.endDate;
  }

  void _loadSelectedCategoryData() {
    final cat = categoryList.firstWhere(
      (c) => c.categoryId == selectedCategoryId.value,
      orElse: () => categoryList.first, // إرجاع أول عنصر كخيار افتراضي
    );
    final budget = cat.budget;

    sliderValue.value = budget?.percentageLimit ?? 25.0;
    percentageController.text = sliderValue.value.toStringAsFixed(0);
    isActive.value = budget?.isActive ?? true;
    startDate.value = budget?.startDate ?? DateTime.now();
    endDate.value =
        budget?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  // منطق الحفظ الذكي (إضافة أو تحديث)
  Future<void> saveOrUpdateBudget(int userId, double value) async {
    if (totalPercentage > 100.01) {
      // 100.01 للسماح بخطأ التقريب
      HelperFunction.showSnackBar(
        "خطأ",
        "مجموع الميزانيات لا يمكن أن يتجاوز 100%",
        isError: true,
      );
      return;
    }
    if (!hasChanged) {
      HelperFunction.showSnackBar(
        "تنبيه",
        "لم تقم بإجراء أي تغييرات",
        isError: true,
      );
      return;
    }
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final cat = categoryList.firstWhere(
        (c) => c.categoryId == selectedCategoryId.value,
      );

      if (cat.budget != null) {
        // تحديث
        cat.budget!.percentageLimit = value;
        cat.budget!.isActive = isActive.value;
        cat.budget!.startDate = startDate.value!;
        cat.budget!.endDate = endDate.value!;
        await updateBudgetUseCase.call(cat.budget!);
        HelperFunction.showSnackBar("نجاح", "تم تحديث الميزانية");
      } else {
        // إضافة (هنا تستدعي AddCategoryBudgetUseCase إذا كانت الدالة موجودة)
        HelperFunction.showSnackBar("تنبيه", "جاري إضافة ميزانية جديدة...");
      }
      listController.loadBudgets(); // تحديث القائمة
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // دوال الـ DatePicker
  Future<void> pickStartDate(BuildContext context) async {
    startDate.value = await HelperFunction.chooseDate(
      context,
      initialDate: startDate.value,
    );
    if (startDate.value != null) startDate.value = startDate.value;
  }

  Future<void> pickEndDate(BuildContext context) async {
    endDate.value = await HelperFunction.chooseDate(
      context,
      initialDate: endDate.value,
    );
    if (endDate.value != null) endDate.value = endDate.value;
  }
}
