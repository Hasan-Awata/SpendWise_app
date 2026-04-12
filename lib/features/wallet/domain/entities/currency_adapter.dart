import 'package:hive/hive.dart';

import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final typeId = 5;

  @override
  Currency read(BinaryReader reader) {
    return Currency.fromJson(reader.read());
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer.write(obj.toJson());
  }
}
