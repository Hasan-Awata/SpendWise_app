import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/widget_feature/helper_widget/custom_text_field.dart';

// // تحسين: تم فصل المنطق البصري عن منطق البيانات لضمان سلاسة الأداء واستخدام الـ Overlay لظهور القائمة فوق العناصر الأخرى
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

class _SPDropdownButtonState extends State<SPDropdownButton>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late List<String> _filteredValues;
  String _selectedText = "";

  // // Logic: استخدام AnimationController لإضافة حركة ناعمة عند ظهور واختفاء القائمة
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _filteredValues = widget.values;
    _setupInitialSelection();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _setupInitialSelection() {
    if (widget.selectedIndex != null &&
        widget.selectedIndex! < widget.values.length) {
      _selectedText = widget.values[widget.selectedIndex!];
    } else {
      _selectedText = widget.hint;
    }
  }

  @override
  void didUpdateWidget(SPDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      _filteredValues = widget.values;
    }
  }

  // // Logic: إدارة الـ Overlay لإظهار القائمة بشكل عائم لا يؤثر على تصميم الصفحة
  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((value) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _filterList(String query) {
    setState(() {
      _filteredValues = widget.values
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (!_isOpen && _filteredValues.isNotEmpty) _openDropdown();
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: SizeTransition(
            sizeFactor: _expandAnimation,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(15),
              clipBehavior: Clip.hardEdge,
              color: SpColor.surfaceNavy,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: widget.textColor.withOpacity(0.3)),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _filteredValues.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _filteredValues[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () => _onItemSelect(_filteredValues[index]),
                      hoverColor: SpColor.accentBlue.withOpacity(0.1),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemSelect(String value) {
    widget.textEditingController?.text = value;
    int originalIndex = widget.values.indexOf(value);
    setState(() {
      _selectedText = value;
      _filteredValues = widget.values;
    });
    _closeDropdown();
    if (widget.onSelected != null) widget.onSelected!(originalIndex, value);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TapRegion(
        onTapOutside: (event) => _closeDropdown(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isTextField
                ? CustomTextField(
                    textColor: widget.textColor,
                    label: widget.title,
                    hint: widget.hint,
                    textEditingController: widget.textEditingController,
                    onTap: _toggleDropdown,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child:
                          widget.suffixIcon ??
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    ),
                    onChanged: (val) {
                      _filterList(val);
                      if (widget.onChanged != null) widget.onChanged!(val);
                    },
                  )
                : _buildStaticSelector(),
          ],
        ),
      ),
    );
  }

  // // Logic: بناء شكل مخصص للاختيار في حال لم يكن حقل نصي، مع إضافة تأثيرات بصرية عند الضغط
  Widget _buildStaticSelector() {
    return InkWell(
      onTap: _toggleDropdown,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: SpColor.surfaceNavy,
          border: Border.all(
            color: _isOpen ? SpColor.accentBlue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              widget.prefixIcon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                _selectedText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: SpColor.offWhite,
                  fontSize: 16,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child:
                  widget.suffixIcon ??
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: SpColor.offWhite,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}
