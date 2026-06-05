import 'package:get/get.dart';
import 'package:spendwise/features/fixed_incomes/data/models/fixedIncome_model.dart';
import 'package:spendwise/features/fixed_incomes/domain/usecases/get_fixed_income_usecase.dart';

class FixedIncomeListController extends GetxController {
  final GetFixedIncomesUseCase getFixedIncomesUseCase;

  FixedIncomeListController({required this.getFixedIncomesUseCase});

  // =========================
  // STATE
  // =========================
  final RxList<FixedIncomeModel> incomesList = <FixedIncomeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // الإجماليات الخاصة بالالتزامات (يمكن عرضها في لوحة التحكم)
  final RxDouble totalMonthlyIncomes = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIncomes(isRefresh: true);
  }

  // =========================
  // FETCH
  // =========================
  // استبدل fetchIncomes بهذه النسخة التي تضمن عدم وجود تكرار
  Future<void> fetchIncomes({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getFixedIncomesUseCase.call();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (data) {
        // بدلاً من التلاعب بالقائمة يدوياً، نحن دائماً نحدث القائمة بناءً على القاعدة
        // وبما أننا نستخدم .assignAll، فهي تمسح القائمة القديمة وتضع الجديدة
        // إذا استمر التكرار، فالمشكلة في الـ Repository (يعيد بيانات مكررة من الـ DB)
        incomesList.assignAll(data);

        incomesList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
        _updateTotals();
      },
    );

    isLoading.value = false;
  }

  // =========================
  // LOCAL OPERATIONS (Optimistic UI)
  // =========================
  void addIncomeLocally(FixedIncomeModel model) {
    incomesList.add(model);
    incomesList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
    _updateTotals();
  }

  void updateIncomeLocally(FixedIncomeModel updated) {
    final index = incomesList.indexWhere(
      (e) => e.fixedIncomeId == updated.fixedIncomeId,
    );
    if (index != -1) {
      incomesList[index] = updated;
      incomesList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
      _updateTotals();
    }
  }

  void deleteIncomeLocally(int id) {
    incomesList.removeWhere((e) => e.fixedIncomeId == id);
    _updateTotals();
  }

  // =========================
  // HELPERS
  // =========================
  void _updateTotals() {
    totalMonthlyIncomes.value = incomesList
        .where((e) => e.isActive)
        .fold(0.0, (sum, item) => sum + item.amount);
    incomesList.refresh();
  }
}
