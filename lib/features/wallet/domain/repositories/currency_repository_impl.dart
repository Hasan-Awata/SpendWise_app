import 'package:spendwise/features/wallet/data/datasources/currency_local.dart';
import 'package:spendwise/features/wallet/data/repositories/currency_repository.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyLocal local;

  CurrencyRepositoryImpl(this.local);

  @override
  Currency? getById(int id) {
    return local.tryCurrencyById(id);
  }
}
