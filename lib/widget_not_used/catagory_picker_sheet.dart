import 'package:flutter/material.dart';
import 'package:get/get.dart';

// تعليق برمجي: واجهة سفلية (Bottom Sheet) تسمح للمستخدم باختيار تصنيف العملية المالية (فاتورة، دين، إلخ).
class CategoryPickerSheet extends StatelessWidget {
  final List<dynamic> categories; // استبدل dynamic بـ CategoryModel الخاص بك
  final Function(dynamic) onSelected;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "اختر الفئة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  onSelected(categories[index]);
                  Get.back();
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      child: Icon(categories[index].icon),
                    ), // فرضاً وجود حقل icon
                    Text(
                      categories[index].name,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
