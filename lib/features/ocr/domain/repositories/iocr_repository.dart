import 'package:spendwise/features/ocr/data/models/invoice_model.dart';

abstract class IOcrRepository {
  Future<Invoice> scanInvoice(String imagePath);
}
