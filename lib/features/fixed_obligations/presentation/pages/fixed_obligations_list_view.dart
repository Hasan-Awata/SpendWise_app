import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/fixed_obligations/data/models/fixed_obligation_model.dart';
import 'package:spendwise/features/fixed_obligations/presentation/manager/fixed_obligation_controller.dart';
import 'package:spendwise/features/fixed_obligations/presentation/manager/fixed_obligation_list_controller.dart';

class FixedObligationListView extends StatelessWidget {
  const FixedObligationListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Get.find<FixedObligationListController>());

    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: SpColor.expenseRed,
        title: const Text(
          "الالتزامات الثابتة",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SpColor.expenseRed,
        onPressed: () => Get.toNamed('/add-fixed-obligation'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "إضافة التزام",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.obligationsList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: SpColor.expenseRed),
          );
        }

        if (controller.obligationsList.isEmpty) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Center(
                  child: Text(
                    "لا توجد التزامات حالياً",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => controller.fetchObligations(),
                    child: const Text(
                      "إعادة المحاولة",
                      style: TextStyle(color: SpColor.expenseRed),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: SpColor.expenseRed,
          onRefresh: () => controller.fetchObligations(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: controller.obligationsList.length,
            itemBuilder: (context, index) {
              final obligation = controller.obligationsList[index];
              return _buildObligationItem(obligation, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildObligationItem(
    FixedObligationModel obligation,
    FixedObligationListController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(child: _buildDetails(obligation)),
          const SizedBox(width: 12),
          _buildActions(obligation),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [SpColor.expenseRed, SpColor.expenseRed.withOpacity(0.7)],
        ),
      ),
      child: const Icon(
        Icons.event_repeat_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildDetails(FixedObligationModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.trim().isEmpty ? 'بدون عنوان' : item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "يوم الاستحقاق: ${item.lastTime.day}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _activeStatus(item.isActive),
      ],
    );
  }

  Widget _activeStatus(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'نشط' : 'متوقف',
        style: TextStyle(
          color: isActive ? Colors.greenAccent : Colors.redAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActions(FixedObligationModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          item.amount.toStringAsFixed(2),
          style: const TextStyle(
            color: SpColor.expenseRed,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            _iconBtn(Icons.delete, const Color.fromRGBO(255, 82, 82, 1), () {
              _showDeleteDialog(item);
            }),
          ],
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // واجهة تأكيد الحذف
  void _showDeleteDialog(FixedObligationModel item) {
    FixedObligationController controller = Get.find();
    Get.defaultDialog(
      backgroundColor: SpColor.surfaceNavy,

      title: "حذف الالتزام",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      middleText:
          "هل أنت متأكد من حذف هذا الالتزام؟ لا يمكن التراجع عن هذا الإجراء.",
      textConfirm: "حذف",
      textCancel: "إلغاء",

      middleTextStyle: TextStyle(color: SpColor.offWhite),
      confirmTextColor: SpColor.offWhite,
      buttonColor: SpColor.expenseRed,
      onConfirm: () {
        controller.deleteObligationLocally(item);
      },
    );
  }

  // void _editFixedIncome(FixedObligationModel item) {
  //   final FixedObligationController controller = Get.find();

  //   // 1. تعبئة الحقول النصية
  //   controller.titleController.text = item.title;
  //   controller.amountController.text = item.amount.toString();

  //   controller.isActive.value = item.isActive;
  //   controller.selectedDate.value = item.lastTime;

  //   // 4. الانتقال لصفحة الإضافة
  //   Get.toNamed(Routes.ADD_FIXEDOBLIGATION);
  // }
}
