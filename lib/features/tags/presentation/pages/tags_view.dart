// // تعليق: إصلاح الربط بين واجهة المستخدم والمتحكم لضمان عمل عمليات الحذف والتعديل بنجاح
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/tags/data/models/tag_model.dart';
import 'package:spendwise/features/tags/presentation/manager/add_tag_controller.dart';
import 'package:spendwise/features/tags/presentation/manager/tag_view_controller.dart';

class TagsView extends GetView<TagViewController> {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    // التأكد من وجود ActionController للقيام بالعمليات
    final actionController = Get.find<TagActionController>();

    return Scaffold(
      backgroundColor: SpColor.primaryDark2,
      appBar: AppBar(
        title: const Text(
          "الأوسمة الخاصة بي",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: SpColor.accentBlue,
        onRefresh: () async => controller.loadTags(isRefresh: true),
        child: Obx(() {
          if (controller.isLoading.value && controller.myTags.isEmpty) {
            return ListView(
              controller: controller.scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              children: [const Center(child: CircularProgressIndicator())],
            );
          }
          return ListView.builder(
            controller: controller.scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: controller.myTags.length,
            itemBuilder: (context, index) {
              final tag = controller.myTags[index];
              return _buildTagCard(tag, actionController);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTagCard(TagModel tag, TagActionController actionController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.label_outline_rounded, color: SpColor.accentBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(tag.name, style: const TextStyle(color: Colors.white)),
          ),
          // // تعليق: ربط الأزرار بالدوال المصلحة
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                onPressed: () => _showUpdateTagDialog(tag, actionController),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.redAccent,
                ),
                onPressed: () => _showDeleteTagDialog(tag, actionController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- الحوارات المصلحة ---

  void _showDeleteTagDialog(
    TagModel tag,
    TagActionController actionController,
  ) {
    Get.defaultDialog(
      title: "حذف الوسم",
      middleText: "هل أنت متأكد من حذف '${tag.name}'؟",
      backgroundColor: SpColor.primaryDark2,
      titleStyle: const TextStyle(color: Colors.redAccent),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "حذف",
      textCancel: "إلغاء",
      onConfirm: () {
        // // تعليق: استدعاء دالة الحذف من المتحكم المسؤول
        actionController.deleteTag(tag);
        Get.back();
      },
    );
  }

  void _showUpdateTagDialog(
    TagModel tag,
    TagActionController actionController,
  ) {
    final nameController = TextEditingController(text: tag.name);

    Get.defaultDialog(
      title: "تعديل الوسم",
      backgroundColor: SpColor.primaryDark2,
      titleStyle: const TextStyle(color: SpColor.accentBlue),
      content: TextField(
        controller: nameController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: "اسم الوسم الجديد"),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: SpColor.accentBlue),
        onPressed: () {
          // // تعليق: استدعاء التحديث وتمرير الاسم الجديد
          actionController.updateTag(tag, nameController.text.trim());
          Get.back();
        },
        child: const Text("تحديث"),
      ),
    );
  }
}
