import 'package:spendwise/features/income/data/models/income_model.dart';
import 'package:spendwise/features/wallet/data/models/wallet_model.dart';

class IncomeViewData {
  final IncomeModel income;
  final WalletModel? wallet;

  IncomeViewData({required this.income, required this.wallet});
}
