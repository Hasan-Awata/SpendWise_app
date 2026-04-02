import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/widget_feature/helper_widget/date_picker_widget.dart';

class IncomeController extends GetxController {
  // --- متغيرات مراقبة (Observable Variables) ---

  // المبلغ المدخل
  var incomeAmount = 0.0.obs;

  // مصدر الدخل (القيمة الافتراضية)
  var selectedValue = "راتب".obs;

  // التاريخ المختار (القيمة الافتراضية اليوم)
  var selectedDate = DateTime.now().obs;

  // قائمة المصادر (يمكن جلبها لاحقاً من قاعدة البيانات)
  var values = <String>["other", "راتب", "عمل حر", "أرباح", "أخرى"].obs;

  // --- وظائف التحكم (Actions) ---

  // تحديث المبلغ
  void updateAmount(String value) {
    incomeAmount.value = double.tryParse(value) ?? 0.0;
  }

  // تحديث المصدر
  void updateSource(String? source) {
    if (source != null) {
      selectedValue.value = source;
    }
  }

  // اختيار التاريخ باستخدام DatePicker

  Future<void> fetchDate(BuildContext context) async {
    DateTime? pickedDate = await HelperFunction.chooseDate(context);
    if (context.mounted) {
      if (pickedDate != null && pickedDate != selectedDate.value) {
        selectedDate.value = pickedDate;
      }
    }
  }

  // وظيفة الحفظ النهائي
  void saveIncome() {
    if (incomeAmount.value <= 0) {
      Get.snackbar(
        "خطأ في الإدخال",
        "يرجى إدخال مبلغ صحيح أكبر من صفر",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // هنا سيتم استدعاء الـ Use Case لإرسال البيانات إلى Oracle DB عبر الـ API
    // بناءً على الـ ERD: سنرسل (Amount, Source, Date, TransactionType: 'Income')

    print(
      "تم حفظ الدخل بنجاح: ${incomeAmount.value} SAR من مصدر: ${selectedValue.value}",
    );

    // بعد الحفظ، ننتقل لواجهة التوزيع (Budget Allocation) التي صممناها سابقاً
    // Get.toNamed('/budget-allocation');
  }
}
