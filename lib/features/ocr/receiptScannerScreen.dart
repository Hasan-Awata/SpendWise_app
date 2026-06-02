import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendwise/core/network/network_service.dart';
import 'package:spendwise/core/routes/app_pages.dart';
import 'package:spendwise/core/utils/colors.dart';
import 'package:spendwise/features/expense/presentation/manager/add_expense_controller.dart';
import 'package:spendwise/features/ocr/ocr_result.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

final NetworkService _networkService = Get.find<NetworkService>();

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // دالة موحدة لاختيار الصورة سواء من الكاميرا أو المعرض
  Future<void> _pickImage(ImageSource source) async {
    // // استدعاء مكتبة ImagePicker لتحديد مصدر الصورة
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        // // تحديث حالة الواجهة بالصورة التي تم اختيارها
        _selectedImage = File(photo.path);
      });
    }
  }

  // // عرض نافذة منبثقة للمستخدم ليختار مصدر الصورة
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مسح الإيصال ضوئيًا")),
      body: Center(
        child: _selectedImage == null ? _buildPlaceholder() : _buildPreview(),
      ),
      // // زر عائم يفتح خيارات الاختيار عند الضغط عليه
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPickerOptions,
        label: const Text("اختيار صورة"),
        icon: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 100, color: Colors.grey[400]),
        const Text("اضغط على الزر لاختيار صورة الإيصال"),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await _networkService.upload(
              endpoint: "ocr",
              file: _selectedImage!,
            );

            if (result != null) {
              final ocrData = OcrResult.fromJson(result);

              // الحصول على الـ Controller وتعبئة البيانات
              final AddExpenseController addExpenseController =
                  Get.find<AddExpenseController>();
              addExpenseController.populateFromOcr(ocrData);

              // الانتقال مباشرة إلى صفحة إضافة المصروف
              Get.toNamed(Routes.ADD_EXPENSE);
            }

            // Get.snackbar("خطأ", "فشل تحليل الإيصال");
          },
          icon: const Icon(Icons.upload_file),
          label: const Text("إرسال للتحليل"),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class EditReceiptScreen extends StatefulWidget {
  final OcrResult result;
  const EditReceiptScreen({super.key, required this.result});

  @override
  State<EditReceiptScreen> createState() => _EditReceiptScreenState();
}

class _EditReceiptScreenState extends State<EditReceiptScreen> {
  late TextEditingController _titleController;
  late TextEditingController _totalController;
  late TextEditingController _taxController;

  // قائمة للمنتجات لتكون قابلة للتعديل
  late List<TextEditingController> _productControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.result.title);
    _totalController = TextEditingController(
      text: widget.result.total.toString(),
    );
    _taxController = TextEditingController(text: widget.result.tax.toString());

    _productControllers = widget.result.products
        .map((p) => TextEditingController(text: p.toString()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مراجعة البيانات"), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // القسم الأساسي
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(
                    _titleController,
                    "اسم المتجر",
                    Icons.storefront,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _totalController,
                          "الإجمالي",
                          Icons.attach_money,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _taxController,
                          "الضريبة",
                          Icons.percent,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            " المنتجات المستخرجة:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // قائمة المنتجات القابلة للتعديل
          ..._productControllers.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: entry.value,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: SpColor.surfaceNavy),
                  ),
                  fillColor: SpColor.mutedGrey,
                  filled: true,
                  labelText: "منتج ${entry.key + 1}",
                  prefixIcon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: SpColor.expenseRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 40),
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                // منطق الحفظ هنا
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                "حفظ الإيصال النهائي",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        fillColor: SpColor.mutedGrey,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
