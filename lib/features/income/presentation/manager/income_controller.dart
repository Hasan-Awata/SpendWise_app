import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/income/data/models/income_model.dart';
// // Import: استيراد الـ Use Cases
import '../../domain/usecases/add_income_usecase.dart';
import '../../domain/usecases/get_incomes_usecase.dart';

class IncomeController extends GetxController {
  // // Clean Architecture: حقن المهام المطلوبة عبر الـ Constructor
  final AddIncomeUsecase addIncomeUseCase;
  final GetIncomesUsecase getIncomesUseCase;

  IncomeController({
    required this.addIncomeUseCase,
    required this.getIncomesUseCase,
  });

  // // --- Observable Variables ---
  TextEditingController descriptionController = TextEditingController();
  var incomeAmount = 0.0.obs;
  var selectedValue = "".obs;
  var selectedDate = DateTime.now().obs;
  var values = <String>[
    "Salary",
    "Freelancing",
    "Profits",
    "Gift",
    "Other",
  ].obs;
  RxBool isUSdollar = false.obs;
  var isFixed = true.obs;
  var isMonthly = true.obs;
  var days = 30.obs;

  // // New Variable: لمراقبة قائمة الدخل الكلية
  var incomesList = <IncomeModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // // Logic: جلب البيانات فور تشغيل الكنترولر
    fetchAllIncomes();
  }

  // // --- Actions / Methods ---

  void updateAmount(String value) {
    incomeAmount.value = double.tryParse(value) ?? 0.0;
  }

  void updateSource(String? source) {
    if (source != null) selectedValue.value = source;
  }

  void toggleFixed(bool value) {
    isFixed.value = value;
    if (!value) {
      isMonthly.value = false;
      days.value = 0;
    }
  }

  Future<void> fetchDate(BuildContext context) async {
    DateTime? pickedDate = await HelperFunction.chooseDate(context);
    if (context.mounted && pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  // // Logic: جلب البيانات من الـ Use Case (الذي يجمع بين الـ API والـ Hive)
  Future<void> fetchAllIncomes() async {
    isLoading.value = true;
    try {
      final results = await getIncomesUseCase();
      incomesList.assignAll(results);
    } catch (e) {
      HelperFunction.showSnackBar(
        "Data Error",
        "Could not fetch data from server",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // // Logic: حفظ البيانات عبر الـ Use Case الفعلي
  Future<void> saveIncome() async {
    if (incomeAmount.value <= 0) {
      HelperFunction.showSnackBar(
        "Input Error",
        "Please enter a valid amount",
        isError: true,
      );
      return;
    }

    if (selectedValue.value.isEmpty) {
      HelperFunction.showSnackBar(
        "Warning",
        "Please select an income source",
        isError: true,
      );
      return;
    }

    isLoading.value = true; // // UI: بدء حالة التحميل
    try {
      final incomeData = IncomeModel(
        id: 0,
        title: selectedValue.value,
        amount: incomeAmount.value,
        isFixed: isFixed.value,
        isMonthly: isFixed.value ? isMonthly.value : false,
        days: (isFixed.value && !isMonthly.value) ? days.value : null,
        lastTime: selectedDate.value,
        currencyId: isUSdollar.value ? 0 : 1,
        userId: 1,
      );

      // // Logic: استدعاء الـ Use Case الفعلي بدلاً من الـ Print
      await addIncomeUseCase(incomeData);

      // // UI Update: إضافة العنصر للقائمة المحلية فوراً
      incomesList.add(incomeData);

      HelperFunction.showSnackBar(
        "Success",
        "Data saved successfully",
        isError: false,
      );
    } catch (e) {
      HelperFunction.showSnackBar(
        "Technical Error",
        "Server connection failed: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
