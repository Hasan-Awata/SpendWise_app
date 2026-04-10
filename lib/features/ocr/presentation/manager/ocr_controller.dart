import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendwise/features/helper_function.dart';
import 'package:spendwise/features/ocr/data/models/invoice_model.dart';
import 'package:spendwise/features/ocr/domain/usecases/scan_invoice_usecase.dart';
import 'package:spendwise/features/ocr/presentation/pages/ocr_result_sheet.dart';

class OcrController extends GetxController {
  final ScanInvoiceUsecase scanInvoiceUsecase;
  OcrController(this.scanInvoiceUsecase);

  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var scannedData = Rxn<Invoice>();

  /// 🔥 الدالة الأساسية (OCR + AI)
  Future<void> scanInvoice() async {
    try {
      // 1️⃣ اختيار صورة
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      isLoading.value = true;

      // 2️⃣ تنفيذ UseCase (OCR + AI)
      final result = await scanInvoiceUsecase.call(image.path);

      // 3️⃣ حفظ النتيجة
      scannedData.value = result;

      // 4️⃣ عرض النتيجة
      _showResultSheet();

      HelperFunction.showSnackBar("Success", "تم استخراج البيانات بنجاح");
    } catch (e) {
      HelperFunction.showSnackBar(
        "Error",
        "فشل في قراءة الفاتورة: ${e.toString()}",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🧠 خيار إضافي: التصوير بالكاميرا
  Future<void> scanFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      isLoading.value = true;

      final result = await scanInvoiceUsecase.call(image.path);

      scannedData.value = result;

      _showResultSheet();

      HelperFunction.showSnackBar("Success", "تم التقاط الفاتورة وتحليلها");
    } catch (e) {
      print("errorr is : ----> ${e}");
      HelperFunction.showSnackBar(
        "Error",
        "فشل في التقاط الفاتورة: ${e.toString()}",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 📊 عرض النتيجة في BottomSheet
  void _showResultSheet() {
    Get.bottomSheet(
      OcrResultSheet(),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enterBottomSheetDuration: const Duration(milliseconds: 400),
      exitBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }
}
