import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

// هذه الصفحة تتيح للمستخدم إنشاء أهداف ادخار جديدة وتحديد المبلغ المستهدف
class AddSavingGoalPage extends StatefulWidget {
  const AddSavingGoalPage({super.key});

  @override
  State<AddSavingGoalPage> createState() => _AddSavingGoalPageState();
}

class _AddSavingGoalPageState extends State<AddSavingGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    // التخلص من المتحكمات عند إغلاق الصفحة لتجنب تسريب الذاكرة
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  // دالة إرسال البيانات والتحقق من صحتها
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    if (target <= 0) {
      Get.snackbar(
        'مبلغ غير صالح', // Invalid amount
        'يرجى إدخال مبلغ مستهدف أكبر من الصفر', // Enter a target greater than zero
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SpColor.expenseRed.withValues(alpha: 0.9),
        colorText: SpColor.offWhite,
      );
      return;
    }

    // هنا يتم ربط منطق الحفظ مع قاعدة البيانات أو المستودع لاحقاً
    debugPrint('Saving goal: ${_nameController.text.trim()}, target: $target');

    Get.snackbar(
      'تم الحفظ', // Saved
      'تمت إضافة هدف الادخار "${_nameController.text.trim()}"', // Saving goal added
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: SpColor.incomeGreen.withValues(alpha: 0.9),
      colorText: SpColor.primaryDark,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark2,
        elevation: 0,
        title: Text(
          'هدف ادخار جديد', // New saving goal
          style: TextStyle(
            color: Colors.amberAccent.withAlpha(195),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.amberAccent.withAlpha(195)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // واجهة المستخدم: حقل إدخال اسم الهدف
                CustomTextField(
                  label: 'اسم الهدف', // Goal name
                  hint: 'مثال: صندوق الطوارئ', // e.g. Emergency fund
                  prefixIcon: const Icon(Icons.flag_outlined),
                  textEditingController: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال اسم الهدف'; // Enter a name
                    }
                    return null;
                  },
                  textColor: Colors.amberAccent.withAlpha(160),
                ),
                const SizedBox(height: 20),

                // واجهة المستخدم: حقل إدخال المبلغ المستهدف
                CustomTextField(
                  label: 'المبلغ المستهدف', // Target amount
                  hint: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  textEditingController: _targetController,
                  isNumber: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال المبلغ المستهدف'; // Enter a target amount
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'يرجى إدخال رقم صحيح'; // Enter a valid number
                    }
                    return null;
                  },
                  textColor: Colors.amberAccent.withAlpha(160),
                ),
                const SizedBox(height: 32),

                // زر الحفظ
                CustomButton(
                  text: "حفظ الهدف", // save goal
                  onPressed: _submit, // تم ربط الدالة هنا
                  color: Colors.amberAccent.withAlpha(195),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
