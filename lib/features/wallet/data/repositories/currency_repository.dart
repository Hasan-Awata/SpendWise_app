import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

abstract class CurrencyRepository {
  Currency? getById(int id);
}
