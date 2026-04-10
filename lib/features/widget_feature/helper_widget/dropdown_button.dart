import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SPDropdownButton extends StatefulWidget {
  final TextEditingController textEditingController;
  final Color textColor;
  final String title;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isTextField;
  final List<String> values;
  final dynamic Function(String)? onChanged;

  const SPDropdownButton({
    super.key,
    this.textColor = SpColor.accentBlue,
    required this.title,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isTextField = true,
    required this.values,
    this.onChanged,
    required this.textEditingController,
  });

  @override
  State<SPDropdownButton> createState() => _SPDropdownButtonState();
}

class _SPDropdownButtonState extends State<SPDropdownButton> {
  // نستخدم Controller واحد لإدارة النص

  bool show = false;
  String selectedtext = "";
  @override
  void initState() {
    super.initState();
    if (widget.values.isNotEmpty) {
      selectedtext = widget.values[0];
    } else {
      selectedtext = widget.hint; // fallback to hint if empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        if (show) {
          setState(() {
            show = false;
          });
        }
      },
      child: Column(
        children: [
          // حقل الإدخال
          widget.isTextField
              ? CustomTextField(
                  textColor: widget.textColor,
                  label: widget.title,
                  hint: widget.hint,
                  textEditingController:
                      widget.textEditingController, // تأكد من اسم المتغير هنا
                  onTap: () => setState(() {
                    show = !show;
                  }),
                  prefixIcon: widget.prefixIcon,
                  onChanged: widget.onChanged,
                  suffixIcon: widget.suffixIcon,
                )
              : GestureDetector(
                  onTap: () => setState(() {
                    show = !show;
                  }),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: SpColor.surfaceNavy,
                    ),
                    child: Row(
                      children: [
                        widget.prefixIcon ?? SizedBox(),
                        SizedBox(width: 30),
                        Expanded(
                          child: Text(
                            selectedtext,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SpColor.offWhite,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        widget.suffixIcon ?? SizedBox(),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: 7),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: show
                  ? widget.values.length > 5
                        ? 200
                        : null
                  : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: widget.values.length,
                  itemBuilder: (context, index) {
                    String itemKey = widget.values[index];
                    return Material(
                      color: SpColor.surfaceNavy,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: () {
                          widget.textEditingController.text = itemKey;
                          selectedtext = itemKey;
                          setState(() => show = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(),
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
