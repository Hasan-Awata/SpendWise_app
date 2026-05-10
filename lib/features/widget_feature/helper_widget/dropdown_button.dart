import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';

class SPDropdownSearch extends StatefulWidget {
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
  State<SPDropdownSearch> createState() => _SPDropdownSearchState();
}

class _SPDropdownSearchState extends State<SPDropdownSearch> {
  String _filter = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "  ${widget.label}",
              style: TextStyle(
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            widget.suffixIcon ?? const SizedBox(),
          ],
        ),
        const SizedBox(height: 6),

        DropdownSearch<String>(
          items: (filter, loadProps) {
            _filter = filter;

            return widget.items
                .where((i) => i.toLowerCase().contains(filter.toLowerCase()))
                .toList();
          },

          selectedItem: widget.selectedItem,
          onChanged: widget.onChanged,

          popupProps: PopupProps.menu(
            showSearchBox: true,
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 300),
            menuProps: MenuProps(
              backgroundColor: SpColor.surfaceNavy, // 🔙 اللون القديم
              borderRadius: BorderRadius.circular(15),
              elevation: 8,
            ),

            itemBuilder: (context, item, isSelected, isFocused) {
              return ListTile(
                title: Text(item, style: const TextStyle(color: Colors.white)),
              );
            },
            // =========================
            // 🔥 LIVE SEARCH FIX
            // =========================
            searchFieldProps: TextFieldProps(
              onChanged: (value) {
                setState(() {
                  _filter = value; // إعادة فلترة فورية
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "بحث سريع...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.themeColor,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFF131722),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            emptyBuilder: (context, searchEntry) => SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  "لا توجد نتائج لـ '$searchEntry'",
                  style: TextStyle(
                    color: widget.themeColor.withOpacity(0.6),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),

          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: SpColor.surfaceNavy,
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
                borderSide: BorderSide(
                  color: widget.themeColor.withOpacity(0.4),
                ),
              ),
            ),
            baseStyle: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
