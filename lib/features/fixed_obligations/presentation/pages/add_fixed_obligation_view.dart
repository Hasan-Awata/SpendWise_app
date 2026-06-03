import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/fixed_obligations/presentation/manager/fixed_obligation_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';

class AddFixedObligationView extends GetView<FixedObligationController> {
  const AddFixedObligationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      backgroundColor: SpColor.primaryDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "التزام ثابت جديد",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // تجميع الحقول الأساسية في بطاقة واحدة منظمة
              _sectionCard(
                children: [
                  _field(
                    "عنوان الالتزام",
                    controller.titleController,
                    Icons.title_rounded,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    "المبلغ (مثال: 150.75)",
                    controller.amountController,
                    Icons.attach_money_rounded,
                    number: true,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    "يوم الاستحقاق (1-31)",
                    controller.dayOfMonthController,
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 20),
                  _buildDatePicker(context),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 20),
                  _buildFixedExpenseSection(),
                ],
              ),

              const SizedBox(height: 30),

              // زر الحفظ
              Obx(
                () => controller.isLoading.value
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 90, 0, 0),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: CustomButton(
                          text: "حفظ الالتزام",
                          onPressed: () => controller.saveFixedObligation(),

                          color: SpColor.expenseRed,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: const Color(0xFF1E293B),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctr,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: ctr,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: SpColor.expenseRed, size: 18),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFixedExpenseSection() {
    return Obx(
      () => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: SpColor.surfaceNavy,
              borderRadius: BorderRadius.circular(20),
              gradient: controller.isActive.value
                  ? LinearGradient(
                      colors: [
                        SpColor.expenseRed,
                        Colors.white.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: controller.isActive.value
                    ? const Color(0xFFF15A5A).withOpacity(0.5)
                    : Colors.white.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            child: Theme(
              data: ThemeData(
                splashColor: const Color(0xFFF15A5A).withOpacity(0.1),
                highlightColor: Colors.transparent,
              ),
              child: SwitchListTile(
                value: controller.isActive.value,
                onChanged: (v) => controller.isActive.value = v,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFF15A5A),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: controller.isActive.value
                          ? const Color(0xFFF15A5A)
                          : Colors.white54,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      " تفعيل الالتزام الثابت",
                      style: TextStyle(
                        color: controller.isActive.value
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: controller.isActive.value
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          "تاريخ الاستحقاق",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => controller.fetchDate(context),
      ),
    );
  }
}
