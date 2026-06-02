import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_action_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class AddTagPage extends StatefulWidget {
  const AddTagPage({super.key});

  @override
  State<AddTagPage> createState() => _AddTagPageState();
}

class _AddTagPageState extends State<AddTagPage> {
  final TagActionController controller = Get.find<TagActionController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020817),

        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "إنشاء وسم جديد",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          actions: [
            IconButton(
              onPressed: () => Get.toNamed(Routes.LIST_TAG),
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            ),
          ],
        ),

        // ================= BODY =================
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "إضافة وسم لتصنيف المصاريف",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 25),

                // ================= CARD =================
                _sectionCard(
                  children: [
                    CustomTextField(
                      label: "اسم الوسم",
                      hint: "مثال: تسوق، طعام، فواتير...",
                      textColor: SpColor.tagColor,
                      prefixIcon: const Icon(
                        Icons.label_important_outline,
                        color: SpColor.tagColor,
                      ),
                      textEditingController: controller.nameController,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _infoBox(),
              ],
            ),
          ),
        ),

        // ================= SAVE BUTTON =================
        bottomNavigationBar: _buildSaveButton(),
      ),
    );
  }

  // ================= CARD STYLE (like expenses) =================
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ================= INFO =================
  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white38, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "الوسوم تساعدك على تصنيف وتحليل المصاريف بشكل ذكي وأكثر وضوح.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SAVE BUTTON =================
  Widget _buildSaveButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 55,
            child: CustomButton(
              text: controller.isLoading.value ? "جاري الحفظ..." : "حفظ الوسم",
              onPressed: controller.isLoading.value
                  ? () {}
                  : () async {
                      FocusScope.of(context).unfocus();
                      await controller.addTag();
                    },
              color: controller.isLoading.value
                  ? Colors.grey
                  : SpColor.tagColor,
            ),
          ),
        ),
      ),
    );
  }
}
