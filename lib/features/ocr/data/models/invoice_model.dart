class Invoice {
  final String title;
  final double amount;
  final String date;

  Invoice({
    required this.title,
    required this.amount,
    required this.date,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      title: json['title'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] ?? '',
    );
  }
}