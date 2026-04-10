import 'package:spendwise/features/ocr/data/models/invoice_model.dart';
import 'package:spendwise/features/ocr/domain/repositories/iocr_repository.dart';

class ScanInvoiceUsecase {
  final IOcrRepository repository;

  ScanInvoiceUsecase(this.repository);

  Future<Invoice> call(String imagePath) {
    return repository.scanInvoice(imagePath);
  }
}
