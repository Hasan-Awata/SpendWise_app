// // [تصميم مطور: قائمة بحث مدمجة وصغيرة تحل مشكلة اللمس وتظهر بذكاء فوق الكيبورد دون شغل كامل الشاشة]
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SPDropdownSearch extends StatelessWidget {
  final List<String> items;
  final String label;
  final String hint;
  final String? selectedItem;
  final Function(String?)? onChanged;
  final Color themeColor;
  final Widget? suffixIcon;

  const SPDropdownSearch({
    super.key,
    required this.items,
    required this.label,
    required this.hint,
    this.selectedItem,
    this.onChanged,
    this.themeColor = const Color(0xFF2196F3),
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "  $label",
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 13, // حجم أصغر ليكون أكثر أناقة
              ),
            ),
            ?suffixIcon,
          ],
        ),
        const SizedBox(height: 6),

        DropdownSearch<String>(
          items: (filter, loadProps) => items
              .where((i) => i.toLowerCase().contains(filter.toLowerCase()))
              .toList(),
          selectedItem: selectedItem,
          onChanged: onChanged,

          // إعدادات القائمة لتكون "منبثقة صغيرة" (Menu) وليس شاشة كاملة
          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose, // يجعل حجم القائمة يتناسب مع عدد العناصر
            constraints: const BoxConstraints(
              maxHeight: 300,
            ), // تحديد أقصى ارتفاع لتبقى الشاشة خلفها مرئية
            emptyBuilder: (context, searchEntry) => SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  "لا توجد نتائج لـ '$searchEntry'",
                  style: TextStyle(
                    color: themeColor.withOpacity(0.6), // هنا يمكنك تغيير اللون
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            menuProps: MenuProps(
              backgroundColor: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(15),
              elevation: 8,
            ),
            searchFieldProps: TextFieldProps(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "بحث سريع...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                prefixIcon: Icon(Icons.search, color: themeColor, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                filled: true,
                fillColor: const Color(0xFF131722),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            itemBuilder: (context, item, isSelected, isFocused) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? themeColor.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: ListTile(
                  visualDensity: VisualDensity
                      .compact, // تقليل المساحات البيضاء ليكون الحجم أصغر
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? themeColor : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),

          // تصميم الحقل الخارجي ليكون متناسقاً مع باقي واجهة Spendwise
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1F2E),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeColor.withOpacity(0.4)),
              ),
            ),
            baseStyle: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
