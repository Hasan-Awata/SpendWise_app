import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSharedDebtView extends StatelessWidget {
  final controller = Get.put(SharedDebtController());

  AddSharedDebtView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        foregroundColor: Color.fromARGB(255, 246, 92, 128),
        title: const Text(
          "إضافة دين جديد",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/shared-debts'),
            icon: const Icon(Icons.list, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  _buildGlassField(
                    controller.titleController,
                    "عنوان الدين",
                    Icons.title_rounded,
                  ),
                  _buildGlassField(
                    controller.amountController,
                    "المبلغ",
                    Icons.attach_money_rounded,
                    isNumber: true,
                  ),
                  _buildGlassField(
                    controller.personController,
                    "اسم المدين",
                    Icons.person_outline_rounded,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // زر الحفظ بتصميم متطور
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 246, 92, 128),
                      Color.fromARGB(255, 133, 49, 87),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 246, 92, 128).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.saveDebt(),
                    child: Center(
                      child: controller.isSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "حفظ الدين",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 246, 92, 128)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class SharedDebtController extends GetxController {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final personController = TextEditingController();
  var isSaving = false.obs;

  void saveDebt() async {
    isSaving.value = true;
    // هنا مكان استدعاء الـ API الخاص بك
    await Future.delayed(const Duration(milliseconds: 800));
    isSaving.value = false;
    Get.back();
    Get.snackbar(
      "تم بنجاح",
      "تمت إضافة الدين المشترك",
      backgroundColor: Colors.greenAccent,
    );
  }
}
