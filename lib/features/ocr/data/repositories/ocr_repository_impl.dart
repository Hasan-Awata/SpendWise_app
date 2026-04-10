import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spendwise/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:spendwise/features/ocr/data/models/invoice_model.dart';
import 'package:spendwise/features/ocr/domain/repositories/iocr_repository.dart';

class OcrRepositoryImpl implements IOcrRepository {
  final OcrLocalDatasource localDatasource;
  final String _ocrApiKey = ""; // OCR.space API
  final String _aiApiKey = ""; // مفتاح OpenAI الخاص بك

  OcrRepositoryImpl(this.localDatasource);

  @override
  Future<Invoice> scanInvoice(String imagePath) async {
    try {
      // ======================
      // 1️⃣ إرسال الصورة إلى OCR
      // ======================
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.ocr.space/parse/image'),
      );

      request.fields['apikey'] = _ocrApiKey;
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      if (res.statusCode != 200) {
        print("OCR Error: ${res.body}");
        throw Exception("Failed OCR with status: ${res.statusCode}");
      }

      final data = jsonDecode(res.body);
      final extractedText = data['ParsedResults'][0]['ParsedText'];
      print("OCR Text: $extractedText");

      // ======================
      // 2️⃣ إرسال النص للـ AI لاستخراج JSON
      // ======================
      final aiResult = await _extractWithAI(extractedText);

      // تحويل النتيجة إلى Invoice
      return Invoice(
        title: aiResult['title'] ?? "Unknown Store",
        amount: aiResult['amount']?.toDouble() ?? 0.0,
        date: aiResult['date'] ?? "",
      );
    } catch (e) {
      print("Execution Error: $e");
      return Invoice(title: "فشل استخراج البيانات", amount: 0.0, date: "");
    }
  }

  // ======================
  // 3️⃣ AI Extraction
  // ======================
  Future<Map<String, dynamic>> _extractWithAI(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    //     final prompt =
    //         """
    // Extract the following fields from the receipt text and return ONLY a JSON object:
    // {
    //   "title": "Store Name",
    //   "amount": 0.0,
    //   "date": "YYYY-MM-DD"
    // }
    // Receipt Text: $text
    // """;

    final prompt = """
write hello
""";

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_aiApiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "temperature": 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      print(jsonDecode(content));
      // تحويل JSON AI إلى Map
      return jsonDecode(content);
    } else {
      print("AI Error: ${response.body}");
      throw Exception("AI Extraction failed: ${response.statusCode}");
    }
  }
}
