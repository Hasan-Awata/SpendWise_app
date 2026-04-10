// // تعليق: الكيان الأساسي للمحفظة والذي يحتوي على البيانات الجوهرية فقط
class WalletEntity {
  final int? walletId;
  final int? userId;
  final int currencyId;
  final double balance;
  // final String title;

  WalletEntity({
    this.walletId,
    this.userId,
    required this.currencyId,
    required this.balance,
    // required this.title,
  });
}
