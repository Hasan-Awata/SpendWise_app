// // تعليق: واجهة إضافة وسم جديد مصلحة مع ربط دقيق لمنطق التحقق والحفظ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
// تأكد أن اسم الكلاس داخل هذا الملف هو TagActionController
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_button.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

// هذه الصفحة تتيح للمستخدم إنشاء وسوم (Tags) جديدة لتصنيف المعاملات المالية
class AddtagPage extends StatefulWidget {
  const AddtagPage({super.key});

  @override
  State<AddtagPage> createState() => _AddtagPageState();
}

class _AddtagPageState extends State<AddtagPage> {
  // استدعاء المتحكم لإدارة حالة إضافة الوسوم
  final TagActionController tagActionController =
      Get.find<TagActionController>();

  // دالة إرسال البيانات واستدعاء منطق الحفظ من المتحكم
  void _submit() async {
    await tagActionController.addTag();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        backgroundColor: SpColor.primaryDark2,
        title: const Text(
          "إنشاء وسم جديد", // Create New Tag
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: SpColor.accentBlue,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: SpColor.accentBlue),
            onPressed: () => Get.toNamed(Routes.LIST_TAG),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "تفاصيل الوسم", // Tag Details
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SpColor.surfaceNavy.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: CustomTextField(
                  label: "اسم الوسم", // Tag Name
                  hint: "مثال: تسوق، فواتير...", // e.g. Shopping, Bills...
                  prefixIcon: const Icon(
                    Icons.label_important_outline,
                    color: SpColor.accentBlue,
                  ),
                  textEditingController: tagActionController.nameController,

                  // // تعليق: منطق التحقق من صحة اسم الوسم قبل الحفظ
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "يرجى إدخال اسم الوسم"; // Please enter a tag name
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoRow(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // عنصر واجهة يعرض معلومة توضيحية للمستخدم حول أهمية الوسوم
  Widget _buildInfoRow() {
    return Row(
      children: const [
        Icon(Icons.info_outline, color: Colors.white38, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            "تساعدك الوسوم على تصنيف مصاريفك بشكل أكثر دقة وتفصيلاً.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // بناء زر الحفظ في أسفل الشاشة مع حالة التحميل
  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => CustomButton(
            onPressed: _submit,
            text: tagActionController.isActionLoading.value
                ? "جاري الحفظ..." // Saving...
                : "حفظ الوسم", // Save Tag
            color: tagActionController.isActionLoading.value
                ? Colors.grey
                : SpColor.accentBlue,
          ),
        ),
      ),
    );
  }
}
