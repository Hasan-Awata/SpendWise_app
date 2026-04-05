import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

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
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    if (target <= 0) {
      Get.snackbar(
        'Invalid amount',
        'Enter a target greater than zero',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: SpColor.expenseRed.withValues(alpha: 0.9),
        colorText: SpColor.offWhite,
      );
      return;
    }

    // Hook for API / repository when backend is wired
    debugPrint('Saving goal: ${_nameController.text.trim()}, target: $target');

    Get.snackbar(
      'Saved',
      'Saving goal "${_nameController.text.trim()}" added',
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
          'New saving goal',
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
                CustomTextField(
                  label: 'Goal name',
                  hint: 'e.g. Emergency fund',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  textEditingController: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                  textColor: Colors.amberAccent.withAlpha(160),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Target amount',
                  hint: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  textEditingController: _targetController,
                  isNumber: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a target amount';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                  textColor: Colors.amberAccent.withAlpha(160),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: "save goal",
                  onPressed: () {},
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
