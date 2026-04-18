import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    this.textColor = const Color(0xFF2196F3),
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

  // // Logic: البحث يبدأ من بداية الكلمة فقط مع تحديث فوري للـ Overlay
  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredValues = widget.values;
      } else {
        _filteredValues = widget.values
            .where((item) => item.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      }

      if (_isOpen) {
        _overlayEntry?.markNeedsBuild();
      } else if (_filteredValues.isNotEmpty) {
        _openDropdown();
      }
    });
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    if (!_isOpen) return;
    _animationController.reverse().then((value) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // // Logic: طبقة شفافة خلفية لإغلاق القائمة عند الضغط في أي مكان خارجها دون تعطيل التمرير
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(15),
                clipBehavior: Clip.hardEdge,
                color: const Color(0xFF1A1F2E),
                child: SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: widget.textColor.withOpacity(0.3),
                      ),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics:
                          const BouncingScrollPhysics(), // تحسين التمرير لشاشات اللمس
                      itemCount: _filteredValues.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 1,
                      ),
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Logic: استخدام onTap الخاص بالـ TextField مباشرة لضمان الاستجابة مع الحفاظ على القدرة على الكتابة
          widget.isTextField
              ? CustomTextField(
                  textColor: widget.textColor,
                  label: widget.title,
                  hint: widget.hint,
                  textEditingController: widget.textEditingController,
                  prefixIcon: widget.prefixIcon,
                  onTap:
                      _openDropdown, // يفتح القائمة عند الضغط للبدء في الكتابة
                  suffixIcon: IconButton(
                    onPressed: _toggleDropdown,
                    icon: AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child:
                          widget.suffixIcon ??
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  onChanged: (val) {
                    _filterList(val);
                    if (widget.onChanged != null) widget.onChanged!(val);
                  },
                )
              : GestureDetector(
                  onTap: _toggleDropdown,
                  child: _buildStaticSelector(),
                ),
        ],
      ),
    );
  }

  Widget _buildStaticSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A1F2E),
        border: Border.all(
          color: _isOpen ? widget.textColor : Colors.transparent,
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
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          AnimatedRotation(
            turns: _isOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child:
                widget.suffixIcon ??
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ],
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
