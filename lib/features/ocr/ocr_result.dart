class OcrResult {
  final String rawText;
  final String title;
  final List<dynamic> products; // يمكن تحويلها لكلاس Product خاص
  final double subtotal;
  final double tax;
  final double total;
  final int categoryId;
  final String date;
  final bool isSuccess;
  final String? errorMessage;

  OcrResult({
    required this.rawText,
    required this.title,
    required this.products,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.categoryId,
    required this.date,
    required this.isSuccess,
    this.errorMessage,
  });

  // // تحويل JSON من الـ C# API إلى كائن Dart
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      rawText: json['rawText'] ?? '',
      title: json['title'] ?? '',
      products: json['products'] ?? [],
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      categoryId: json['categoryId'] ?? 0,
      date: json['date'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}
