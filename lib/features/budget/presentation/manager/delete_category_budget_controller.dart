// delete_category_budget_controller.dart

import 'package:get/get.dart';
import 'package:spendwise/core/error/failure.dart';
import 'package:spendwise/features/budget/domain/entities/category_budget_entity.dart';
import 'package:spendwise/features/budget/domain/usecases/delete_category_budget_usecase.dart';
import 'package:spendwise/features/budget/presentation/manager/category_budget_list_controller.dart';
import 'package:spendwise/features/helper_function.dart';

class DeleteCategoryBudgetController extends GetxController {
  final DeleteCategoryBudgetUseCase deleteBudgetUseCase;

  DeleteCategoryBudgetController({required this.deleteBudgetUseCase});

  final isLoading = false.obs;

  Future<void> deleteBudget(CategoryBudgetEntity budget) async {
    try {
      isLoading.value = true;

      final result = await deleteBudgetUseCase(budget);

      result.fold(
        (failure) {
          HelperFunction.showSnackBar(
            "خطأ",
            _mapFailure(failure),
            isError: true,
          );
        },
        (_) {
          // جلب وحدة التحكم الخاصة بالقائمة للقيام بحذف ذكي وفوري من الذاكرة
          if (Get.isRegistered<CategoryBudgetListController>()) {
            final listController = Get.find<CategoryBudgetListController>();

            // تصفية المصفوفة بناءً على الفئة المعنية بالميزانية المحذوفة
            listController.budgets.removeWhere(
              (b) => b.categoryId == budget.categoryId,
            );

            // إجبار واجهات GetX ومستمعي الـ UI على إعادة البناء الفوري بدون تأخير
            listController.budgets.refresh();
          }

          Get.back(result: true);
          // HelperFunction.showSnackBar("نجاح", "تم حذف الميزانية بنجاح");
        },
      );
    } catch (e) {
      HelperFunction.showSnackBar("خطأ", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFailure(Failure failure) {
    return failure.message;
  }
}
