// // تعليق: استبدال حزمة http القديمة واستخدام الـ NetworkService الموحد لضمان معالجة الأخطاء والمزامنة التلقائية للميزانيات بحسب الهيكلية الجديدة
import 'package:spendwise/core/network/api_endpoints.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/features/budget/data/datasource/category_budget_remote_datasource.dart';
import 'package:spendwise/features/budget/data/model/category_budget_model.dart';

class CategoryBudgetRemoteDatasourceImpl
    implements CategoryBudgetRemoteDatasource {
  final NetworkService network;

  CategoryBudgetRemoteDatasourceImpl({required this.network});

  // =========================
  // GET BUDGETS
  // =========================
  @override
  Future<List<CategoryBudgetModel>> getBudgets() async {
    // استخدام الـ network.request النظيف الذي يتعامل مع الـ Headers والـ Decoded JSON تلقائياً
    final result = await network.request(
      endpoint: ApiEndpoints.categories,
      method: "GET",
    );

    return (result as List)
        .map((e) => CategoryBudgetModel.fromJson(e))
        .toList();
  }

  // =========================
  // ADD BUDGET
  // =========================
  @override
  Future<CategoryBudgetModel> addBudget(CategoryBudgetModel budget) async {
    // صياغة ماب البيانات بشكل مرن يدعم الـ PascalCase والـ camelCase تفادياً لمشاكل الـ SQL Server المخفية
    final Map<String, dynamic> bodyData = budget.toJson();

    final result = await network.request(
      endpoint: ApiEndpoints.categories,
      method: "POST",
      body: bodyData,
    );

    // التعامل مع النتيجة المرتجعة بمرونة كاملة في حال أعاد السيرفر معرف رقمي أو الكائن بالكامل
    if (result is int) {
      budget.categoryId =
          result; // فرضاً أن الكائن يمتلك خاصية المعرف لتحديثها محلياً
      return budget;
    } else if (result is Map<String, dynamic>) {
      return CategoryBudgetModel.fromJson(result);
    } else {
      return budget;
    }
  }

  // =========================
  // UPDATE BUDGET
  // =========================
  @override
  Future<CategoryBudgetModel> updateBudget(CategoryBudgetModel budget) async {
    print("Budget is ---> ${budget.toJson()}"); // اجلب الـ JSON المحدث
    final Map<String, dynamic> bodyData = budget.toJson();

    // تأكد أن الـ ID في الـ Body مطابق للـ ID في الـ Route
    bodyData['CategoryId'] = budget.categoryId;

    await network.request(
      endpoint: "${ApiEndpoints.categories}/${budget.categoryId}",
      method: "PATCH",
      body: bodyData,
    );

    return budget;
  }

  // =========================
  // DELETE BUDGET
  // =========================
  @override
  Future<bool> deleteBudget(int categoryId) async {
    try {
      await network.request(
        endpoint: "${ApiEndpoints.categories}/$categoryId",
        method: "DELETE",
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
