import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrLocalDatasource {
  final TextRecognizer _recognizer = TextRecognizer();

  // هذه الدالة تستخرج النص بهيكلية واضحة (فقرات وأسطر) لتسهيل معالجتها بواسطة الـ AI
  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText result = await _recognizer.processImage(inputImage);

    StringBuffer structuredText = StringBuffer();

    // نقوم بالمرور على الكتل (Blocks) لأنها تمثل "الفقرات" المنطقية في الصورة
    for (TextBlock block in result.blocks) {
      for (TextLine line in block.lines) {
        // ندمج الأسطر داخل الكتلة الواحدة مع مسافة بسيطة
        structuredText.write('${line.text} ');
      }
      // نضع فاصل سطرين بين كل كتلة وأخرى ليعرف الـ AI أنها فقرة جديدة
      structuredText.write('\n\n');
    }

    return structuredText.toString().trim();
  }
}
