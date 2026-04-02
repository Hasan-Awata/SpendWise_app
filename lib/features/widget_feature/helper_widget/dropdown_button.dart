import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

class SPDropdownButton extends StatefulWidget {
  final dynamic controller;
  final Color textColor;
  final String title;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const SPDropdownButton({
    super.key,
    required this.controller,
    this.textColor = SpColor.accentBlue,
    required this.title,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<SPDropdownButton> createState() => _SPDropdownButtonState();
}

class _SPDropdownButtonState extends State<SPDropdownButton> {
  // نستخدم Controller واحد لإدارة النص
  TextEditingController textEditingController = TextEditingController();
  bool show = false;

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
          CustomTextField(
            textColor: widget.textColor,
            label: widget.title,
            hint: widget.hint,
            textEditingController:
                textEditingController, // تأكد من اسم المتغير هنا
            onTap: () => setState(() {
              show = !show;
            }),
            prefixIcon: widget.prefixIcon,
            onChanged: (v) => widget.controller.selectedValue.value = v,
            suffixIcon: widget.suffixIcon,
          ),

          // استخدام AnimatedSize لجعل التمدد سلاساً
          AnimatedSize(
            duration: const Duration(milliseconds: 300),

            curve: Curves.easeInOut,

            child: SizedBox(
              height: show ? 200 : 0,
              child: Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.controller.values.length,
                    itemBuilder: (context, index) {
                      final String item = widget.controller.values[index];
                      return Material(
                        color: SpColor.surfaceNavy,

                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: InkWell(
                          onTap: () {
                            textEditingController.text = item;
                            widget.controller.selectedValue.value = item;
                            setState(() => show = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(),
                            child: Text(
                              item,
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
          ),
        ],
      ),
    );
  }
}
