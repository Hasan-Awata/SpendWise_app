import 'package:get/get.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/domain/usecases/get_fixed_obligation_usecase.dart';

class FixedObligationListController extends GetxController {
  final GetFixedObligationsUseCase getFixedObligationsUseCase;

  FixedObligationListController({required this.getFixedObligationsUseCase});

  @override
  void onInit() {
    super.onInit();

    fetchObligations(isRefresh: true);
  }

  // =========================
  // STATE
  // =========================
  final RxList<FixedObligationModel> obligationsList =
      <FixedObligationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // الإجماليات الخاصة بالالتزامات (يمكن عرضها في لوحة التحكم)
  final RxDouble totalMonthlyObligations = 0.0.obs;

  // =========================
  // FETCH
  // =========================
  Future<void> fetchObligations({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getFixedObligationsUseCase.call();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (data) {
        obligationsList.assignAll(data);
        // ترتيب الالتزامات حسب تاريخ الاستحقاق (الأقرب أولاً)
        obligationsList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
        _updateTotals();
      },
    );

    isLoading.value = false;
  }

  // =========================
  // LOCAL OPERATIONS (Optimistic UI)
  // =========================
  void addObligationLocally(FixedObligationModel model) {
    obligationsList.add(model);
    obligationsList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
    _updateTotals();
  }

  void updateObligationLocally(FixedObligationModel updated) {
    final index = obligationsList.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      obligationsList[index] = updated;
      obligationsList.sort((a, b) => a.lastTime.compareTo(b.lastTime));
      _updateTotals();
    }
  }

  void deleteObligationLocally(int id) {
    obligationsList.removeWhere((e) => e.id == id);
    _updateTotals();
  }

  // =========================
  // HELPERS
  // =========================
  void _updateTotals() {
    totalMonthlyObligations.value = obligationsList
        .where((e) => e.isActive)
        .fold(0.0, (sum, item) => sum + item.amount);
    obligationsList.refresh();
  }
}
