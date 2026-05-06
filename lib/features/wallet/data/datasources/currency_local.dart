import 'package:hive/hive.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class CurrencyLocal {
  static final CurrencyLocal _instance = CurrencyLocal._internal();
  CurrencyLocal._internal();
  factory CurrencyLocal() => _instance;

  late Box _box;
  // List of updated currencies for SpendWise application
  final List<Currency> allCurrencies = [
    Currency(id: 1, code: "SYP", currencyName: "Syrian Pound", actualValue: 1),
    Currency(
      id: 2,
      code: "USD",
      currencyName: "United States Dollar",
      actualValue: 1,
    ),
    Currency(id: 3, code: "EUR", currencyName: "Euro", actualValue: 1),
    Currency(id: 4, code: "TRY", currencyName: "Turkish Lira", actualValue: 1),
    Currency(id: 5, code: "SAR", currencyName: "Saudi Riyal", actualValue: 1),
    Currency(
      id: 6,
      code: "AED",
      currencyName: "United Arab Emirates Dirham",
      actualValue: 1,
    ),
    Currency(
      id: 7,
      code: "EGP",
      currencyName: "Egyptian Pound",
      actualValue: 1,
    ),
    Currency(id: 8, code: "LYD", currencyName: "Libyan Dinar", actualValue: 1),
    Currency(
      id: 9,
      code: "JOD",
      currencyName: "Jordanian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 10,
      code: "KWD",
      currencyName: "Kuwaiti Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 11,
      code: "GBP",
      currencyName: "British Pound Sterling",
      actualValue: 1,
    ),
    Currency(id: 12, code: "QAR", currencyName: "Qatari Riyal", actualValue: 1),
    Currency(
      id: 13,
      code: "BHD",
      currencyName: "Bahraini Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 14,
      code: "SEK",
      currencyName: "Swedish Krona",
      actualValue: 1,
    ),
    Currency(
      id: 15,
      code: "CAD",
      currencyName: "Canadian Dollar",
      actualValue: 1,
    ),
    Currency(id: 16, code: "OMR", currencyName: "Omani Rial", actualValue: 1),
    Currency(
      id: 17,
      code: "NOK",
      currencyName: "Norwegian Krone",
      actualValue: 1,
    ),
    Currency(id: 18, code: "DKK", currencyName: "Danish Krone", actualValue: 1),
    Currency(
      id: 19,
      code: "DZD",
      currencyName: "Algerian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 20,
      code: "MAD",
      currencyName: "Moroccan Dirham",
      actualValue: 1,
    ),
    Currency(
      id: 21,
      code: "TND",
      currencyName: "Tunisian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 22,
      code: "RUB",
      currencyName: "Russian Ruble",
      actualValue: 1,
    ),
    Currency(
      id: 23,
      code: "MYR",
      currencyName: "Malaysian Ringgit",
      actualValue: 1,
    ),
    Currency(
      id: 24,
      code: "BRL",
      currencyName: "Brazilian Real",
      actualValue: 1,
    ),
    Currency(
      id: 25,
      code: "NZD",
      currencyName: "New Zealand Dollar",
      actualValue: 1,
    ),
    Currency(id: 26, code: "CHF", currencyName: "Swiss Franc", actualValue: 1),
    Currency(
      id: 27,
      code: "AUD",
      currencyName: "Australian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 28,
      code: "ZAR",
      currencyName: "South African Rand",
      actualValue: 1,
    ),
    Currency(id: 29, code: "IQD", currencyName: "Iraqi Dinar", actualValue: 1),
    Currency(
      id: 30,
      code: "SGD",
      currencyName: "Singapore Dollar",
      actualValue: 1,
    ),
  ];
  Future<void> initializaCurrencies() async {
    try {
      _box = await Hive.openBox<Currency>('currencies_box');
      if (_box.isEmpty) {
        for (var currency in allCurrencies) {
          await _box.put(currency.currencyName, currency);
        }
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<Currency> getCurrency(String name) async {
    var currency = await _box.get(name);
    try {
      if (currency == null) {
        return allCurrencies[1];
      }
      return currency;
    } catch (_) {
      rethrow;
    }
  }

  /// يطابق معرف العملة كما يُخزَّن في المحفظة (CurrencyId) مع القائمة المحلية.
  Currency? tryCurrencyById(int id) {
    for (final c in allCurrencies) {
      if (c.id == id) return c;
    }
    return null;
  }
}
