class WalletTransactionResult {
  final bool success;

  final double deductedFromMain;

  final double deductedFromSavings;

  final String? message;

  const WalletTransactionResult({
    required this.success,
    this.deductedFromMain = 0,
    this.deductedFromSavings = 0,
    this.message,
  });
}
