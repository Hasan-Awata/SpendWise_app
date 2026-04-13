import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SPDropdownButton extends StatefulWidget {
  final TextEditingController? textEditingController;
  final Color textColor;
  final String title;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isTextField;
  final List<String> values;

  final dynamic Function(String)? onChanged;
  final Function(int index, String value)? onSelected;
  final int? selectedIndex;

  const SPDropdownButton({
    super.key,
    this.textColor = SpColor.accentBlue,
    required this.title,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isTextField = true,
    required this.values,
    this.onSelected,
    this.textEditingController,
    this.selectedIndex,
    this.onChanged,
  });

  @override
  State<SPDropdownButton> createState() => _SPDropdownButtonState();
}

class _SPDropdownButtonState extends State<SPDropdownButton> {
  bool show = false;
  String selectedtext = "";

  // // تعليق: قائمة داخلية لإدارة العناصر المفلترة أثناء البحث
  List<String> filteredValues = [];

  @override
  void initState() {
    super.initState();
    // تهيئة القائمة المفلترة بكافة القيم عند البداية
    filteredValues = widget.values;

    if (widget.selectedIndex != null &&
        widget.selectedIndex! < widget.values.length) {
      selectedtext = widget.values[widget.selectedIndex!];
    } else if (widget.values.isNotEmpty) {
      selectedtext = widget.values[0];
    } else {
      selectedtext = widget.hint;
    }
  }

  @override
  void didUpdateWidget(SPDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      final q = widget.textEditingController?.text ?? '';
      setState(() {
        if (q.isEmpty) {
          filteredValues = List<String>.from(widget.values);
        } else {
          filteredValues = widget.values
              .where((item) => item.toLowerCase().startsWith(q.toLowerCase()))
              .toList();
        }
      });
    }
  }

  // // Logic: تعديل دالة الفلترة لتبحث عن العناصر التي تبدأ بالأحرف المُدخلة فقط
  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredValues = widget.values;
      } else {
        filteredValues = widget.values
            .where((item) => item.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      }
      // إظهار القائمة تلقائياً عند البدء بالكتابة لتسهيل الاختيار
      show = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        if (show) setState(() => show = false);
      },
      child: Column(
        children: [
          widget.isTextField
              ? CustomTextField(
                  textColor: widget.textColor,
                  label: widget.title,
                  hint: widget.hint,
                  textEditingController: widget.textEditingController,
                  onTap: () => setState(() => show = !show),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  onChanged: (val) {
                    // تنفيذ الفلترة الداخلية
                    _filterList(val);
                    // تنفيذ الـ onChanged الخارجي إذا وُجد
                    if (widget.onChanged != null) widget.onChanged!(val);
                  },
                )
              : GestureDetector(
                  onTap: () => setState(() => show = !show),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: SpColor.surfaceNavy,
                    ),
                    child: Row(
                      children: [
                        widget.prefixIcon ?? const SizedBox(),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Text(
                            selectedtext,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SpColor.offWhite,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        widget.suffixIcon ?? const SizedBox(),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 7),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              // // Logic: تحديد الارتفاع بناءً على نتائج البحث (filteredValues)
              height: show ? (filteredValues.length > 5 ? 200 : null) : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: filteredValues.length,
                  itemBuilder: (context, index) {
                    String itemKey = filteredValues[index];
                    return Material(
                      color: SpColor.surfaceNavy,
                      child: InkWell(
                        onTap: () {
                          widget.textEditingController?.text = itemKey;

                          int originalIndex = widget.values.indexOf(itemKey);
                          setState(() {
                            selectedtext = itemKey;
                            show = false;
                            // إعادة القائمة لحالتها الكاملة بعد الاختيار
                            filteredValues = widget.values;
                          });

                          if (widget.onSelected != null) {
                            widget.onSelected!(originalIndex, itemKey);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          child: Text(
                            itemKey,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
