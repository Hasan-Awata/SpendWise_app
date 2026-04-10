import 'package:get/get.dart';
import 'package:spendwise/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:spendwise/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:spendwise/features/ocr/domain/repositories/iocr_repository.dart';
import 'package:spendwise/features/ocr/domain/usecases/scan_invoice_usecase.dart';
import 'package:spendwise/features/ocr/presentation/manager/ocr_controller.dart';

class OcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OcrLocalDatasource());
    Get.lazyPut<IOcrRepository>(() => OcrRepositoryImpl(Get.find()));
    Get.lazyPut(() => ScanInvoiceUsecase(Get.find()));
    Get.lazyPut(() => OcrController(Get.find()));
  }
}
