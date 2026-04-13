import 'package:hive/hive.dart';
import 'package:spendwise/features/wallet/domain/entities/currency_model.dart';

class CurrencyLocal {
  static final CurrencyLocal _instance = CurrencyLocal._internal();
  CurrencyLocal._internal();
  factory CurrencyLocal() => _instance;

  late Box _box;

  final List<Currency> allCurrencies = [
    Currency(
      id: 1,
      code: "AFN",
      currencyName: "Afghan Afghani",
      actualValue: 1,
    ),
    Currency(id: 2, code: "ALL", currencyName: "Albanian Lek", actualValue: 1),
    Currency(
      id: 3,
      code: "DZD",
      currencyName: "Algerian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 4,
      code: "AOA",
      currencyName: "Angolan Kwanza",
      actualValue: 1,
    ),
    Currency(
      id: 5,
      code: "ARS",
      currencyName: "Argentine Peso",
      actualValue: 1,
    ),
    Currency(id: 6, code: "AMD", currencyName: "Armenian Dram", actualValue: 1),
    Currency(id: 7, code: "AWG", currencyName: "Aruban Florin", actualValue: 1),
    Currency(
      id: 8,
      code: "AUD",
      currencyName: "Australian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 9,
      code: "AZN",
      currencyName: "Azerbaijani Manat",
      actualValue: 1,
    ),
    Currency(
      id: 10,
      code: "BSD",
      currencyName: "Bahamian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 11,
      code: "BHD",
      currencyName: "Bahraini Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 12,
      code: "BDT",
      currencyName: "Bangladeshi Taka",
      actualValue: 1,
    ),
    Currency(
      id: 13,
      code: "BBD",
      currencyName: "Barbadian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 14,
      code: "BYN",
      currencyName: "Belarusian Ruble",
      actualValue: 1,
    ),
    Currency(
      id: 15,
      code: "BZD",
      currencyName: "Belize Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 16,
      code: "BMD",
      currencyName: "Bermudian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 17,
      code: "BTN",
      currencyName: "Bhutanese Ngultrum",
      actualValue: 1,
    ),
    Currency(
      id: 18,
      code: "BOB",
      currencyName: "Bolivian Boliviano",
      actualValue: 1,
    ),
    Currency(
      id: 19,
      code: "BAM",
      currencyName: "Bosnia and Herzegovina Convertible Mark",
      actualValue: 1,
    ),
    Currency(
      id: 20,
      code: "BWP",
      currencyName: "Botswana Pula",
      actualValue: 1,
    ),
    Currency(
      id: 21,
      code: "BRL",
      currencyName: "Brazilian Real",
      actualValue: 1,
    ),
    Currency(
      id: 22,
      code: "BND",
      currencyName: "Brunei Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 23,
      code: "BGN",
      currencyName: "Bulgarian Lev",
      actualValue: 1,
    ),
    Currency(
      id: 24,
      code: "BIF",
      currencyName: "Burundian Franc",
      actualValue: 1,
    ),
    Currency(
      id: 25,
      code: "KHR",
      currencyName: "Cambodian Riel",
      actualValue: 1,
    ),
    Currency(
      id: 26,
      code: "CAD",
      currencyName: "Canadian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 27,
      code: "CVE",
      currencyName: "Cape Verdean Escudo",
      actualValue: 1,
    ),
    Currency(
      id: 28,
      code: "KYD",
      currencyName: "Cayman Islands Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 29,
      code: "XAF",
      currencyName: "Central African CFA Franc",
      actualValue: 1,
    ),
    Currency(id: 30, code: "CLP", currencyName: "Chilean Peso", actualValue: 1),
    Currency(
      id: 31,
      code: "CNY",
      currencyName: "Chinese Yuan Renminbi",
      actualValue: 1,
    ),
    Currency(
      id: 32,
      code: "COP",
      currencyName: "Colombian Peso",
      actualValue: 1,
    ),
    Currency(
      id: 33,
      code: "KMF",
      currencyName: "Comorian Franc",
      actualValue: 1,
    ),
    Currency(
      id: 34,
      code: "CDF",
      currencyName: "Congolese Franc",
      actualValue: 1,
    ),
    Currency(
      id: 35,
      code: "CRC",
      currencyName: "Costa Rican Colon",
      actualValue: 1,
    ),
    Currency(
      id: 36,
      code: "HRK",
      currencyName: "Croatian Kuna",
      actualValue: 1,
    ),
    Currency(id: 37, code: "CUP", currencyName: "Cuban Peso", actualValue: 1),
    Currency(id: 38, code: "CZK", currencyName: "Czech Koruna", actualValue: 1),
    Currency(id: 39, code: "DKK", currencyName: "Danish Krone", actualValue: 1),
    Currency(
      id: 40,
      code: "DJF",
      currencyName: "Djiboutian Franc",
      actualValue: 1,
    ),
    Currency(
      id: 41,
      code: "DOP",
      currencyName: "Dominican Peso",
      actualValue: 1,
    ),
    Currency(
      id: 42,
      code: "XCD",
      currencyName: "East Caribbean Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 43,
      code: "EGP",
      currencyName: "Egyptian Pound",
      actualValue: 1,
    ),
    Currency(
      id: 44,
      code: "ERN",
      currencyName: "Eritrean Nakfa",
      actualValue: 1,
    ),
    Currency(
      id: 45,
      code: "ETB",
      currencyName: "Ethiopian Birr",
      actualValue: 1,
    ),
    Currency(id: 46, code: "EUR", currencyName: "Euro", actualValue: 1),
    Currency(
      id: 47,
      code: "FKP",
      currencyName: "Falkland Islands Pound",
      actualValue: 1,
    ),
    Currency(
      id: 48,
      code: "FJD",
      currencyName: "Fijian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 49,
      code: "GMD",
      currencyName: "Gambian Dalasi",
      actualValue: 1,
    ),
    Currency(
      id: 50,
      code: "GEL",
      currencyName: "Georgian Lari",
      actualValue: 1,
    ),
    Currency(
      id: 51,
      code: "GHS",
      currencyName: "Ghanaian Cedi",
      actualValue: 1,
    ),
    Currency(
      id: 52,
      code: "GIP",
      currencyName: "Gibraltar Pound",
      actualValue: 1,
    ),
    Currency(
      id: 53,
      code: "GTQ",
      currencyName: "Guatemalan Quetzal",
      actualValue: 1,
    ),
    Currency(
      id: 54,
      code: "GNF",
      currencyName: "Guinean Franc",
      actualValue: 1,
    ),
    Currency(
      id: 55,
      code: "GYD",
      currencyName: "Guyanese Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 56,
      code: "HTG",
      currencyName: "Haitian Gourde",
      actualValue: 1,
    ),
    Currency(
      id: 57,
      code: "HNL",
      currencyName: "Honduran Lempira",
      actualValue: 1,
    ),
    Currency(
      id: 58,
      code: "HKD",
      currencyName: "Hong Kong Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 59,
      code: "HUF",
      currencyName: "Hungarian Forint",
      actualValue: 1,
    ),
    Currency(
      id: 60,
      code: "ISK",
      currencyName: "Icelandic Krona",
      actualValue: 1,
    ),
    Currency(id: 61, code: "INR", currencyName: "Indian Rupee", actualValue: 1),
    Currency(
      id: 62,
      code: "IDR",
      currencyName: "Indonesian Rupiah",
      actualValue: 1,
    ),
    Currency(id: 63, code: "IRR", currencyName: "Iranian Rial", actualValue: 1),
    Currency(id: 64, code: "IQD", currencyName: "Iraqi Dinar", actualValue: 1),
    Currency(
      id: 65,
      code: "JMD",
      currencyName: "Jamaican Dollar",
      actualValue: 1,
    ),
    Currency(id: 66, code: "JPY", currencyName: "Japanese Yen", actualValue: 1),
    Currency(
      id: 67,
      code: "JOD",
      currencyName: "Jordanian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 68,
      code: "KZT",
      currencyName: "Kazakhstani Tenge",
      actualValue: 1,
    ),
    Currency(
      id: 69,
      code: "KES",
      currencyName: "Kenyan Shilling",
      actualValue: 1,
    ),
    Currency(
      id: 70,
      code: "KWD",
      currencyName: "Kuwaiti Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 71,
      code: "KGS",
      currencyName: "Kyrgyzstani Som",
      actualValue: 1,
    ),
    Currency(id: 72, code: "LAK", currencyName: "Lao Kip", actualValue: 1),
    Currency(
      id: 73,
      code: "LBP",
      currencyName: "Lebanese Pound",
      actualValue: 1,
    ),
    Currency(id: 74, code: "LSL", currencyName: "Lesotho Loti", actualValue: 1),
    Currency(
      id: 75,
      code: "LRD",
      currencyName: "Liberian Dollar",
      actualValue: 1,
    ),
    Currency(id: 76, code: "LYD", currencyName: "Libyan Dinar", actualValue: 1),
    Currency(
      id: 77,
      code: "MOP",
      currencyName: "Macanese Pataca",
      actualValue: 1,
    ),
    Currency(
      id: 78,
      code: "MKD",
      currencyName: "Macedonian Denar",
      actualValue: 1,
    ),
    Currency(
      id: 79,
      code: "MGA",
      currencyName: "Malagasy Ariary",
      actualValue: 1,
    ),
    Currency(
      id: 80,
      code: "MWK",
      currencyName: "Malawian Kwacha",
      actualValue: 1,
    ),
    Currency(
      id: 81,
      code: "MYR",
      currencyName: "Malaysian Ringgit",
      actualValue: 1,
    ),
    Currency(
      id: 82,
      code: "MVR",
      currencyName: "Maldivian Rufiyaa",
      actualValue: 1,
    ),
    Currency(
      id: 83,
      code: "MRU",
      currencyName: "Mauritanian Ouguiya",
      actualValue: 1,
    ),
    Currency(
      id: 84,
      code: "MUR",
      currencyName: "Mauritian Rupee",
      actualValue: 1,
    ),
    Currency(id: 85, code: "MXN", currencyName: "Mexican Peso", actualValue: 1),
    Currency(id: 86, code: "MDL", currencyName: "Moldovan Leu", actualValue: 1),
    Currency(
      id: 87,
      code: "MNT",
      currencyName: "Mongolian Tugrik",
      actualValue: 1,
    ),
    Currency(
      id: 88,
      code: "MAD",
      currencyName: "Moroccan Dirham",
      actualValue: 1,
    ),
    Currency(
      id: 89,
      code: "MZN",
      currencyName: "Mozambican Metical",
      actualValue: 1,
    ),
    Currency(id: 90, code: "MMK", currencyName: "Myanmar Kyat", actualValue: 1),
    Currency(
      id: 91,
      code: "NAD",
      currencyName: "Namibian Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 92,
      code: "NPR",
      currencyName: "Nepalese Rupee",
      actualValue: 1,
    ),
    Currency(
      id: 93,
      code: "ANG",
      currencyName: "Netherlands Antillean Guilder",
      actualValue: 1,
    ),
    Currency(
      id: 94,
      code: "TWD",
      currencyName: "New Taiwan Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 95,
      code: "NZD",
      currencyName: "New Zealand Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 96,
      code: "NIO",
      currencyName: "Nicaraguan Cordoba",
      actualValue: 1,
    ),
    Currency(
      id: 97,
      code: "NGN",
      currencyName: "Nigerian Naira",
      actualValue: 1,
    ),
    Currency(
      id: 98,
      code: "KPW",
      currencyName: "North Korean Won",
      actualValue: 1,
    ),
    Currency(
      id: 99,
      code: "NOK",
      currencyName: "Norwegian Krone",
      actualValue: 1,
    ),
    Currency(id: 100, code: "OMR", currencyName: "Omani Rial", actualValue: 1),
    Currency(
      id: 101,
      code: "PKR",
      currencyName: "Pakistani Rupee",
      actualValue: 1,
    ),
    Currency(
      id: 102,
      code: "PAB",
      currencyName: "Panamanian Balboa",
      actualValue: 1,
    ),
    Currency(
      id: 103,
      code: "PGK",
      currencyName: "Papua New Guinean Kina",
      actualValue: 1,
    ),
    Currency(
      id: 104,
      code: "PYG",
      currencyName: "Paraguayan Guarani",
      actualValue: 1,
    ),
    Currency(
      id: 105,
      code: "PEN",
      currencyName: "Peruvian Sol",
      actualValue: 1,
    ),
    Currency(
      id: 106,
      code: "PHP",
      currencyName: "Philippine Peso",
      actualValue: 1,
    ),
    Currency(
      id: 107,
      code: "PLN",
      currencyName: "Polish Zloty",
      actualValue: 1,
    ),
    Currency(
      id: 108,
      code: "QAR",
      currencyName: "Qatari Riyal",
      actualValue: 1,
    ),
    Currency(
      id: 109,
      code: "RON",
      currencyName: "Romanian Leu",
      actualValue: 1,
    ),
    Currency(
      id: 110,
      code: "RUB",
      currencyName: "Russian Ruble",
      actualValue: 1,
    ),
    Currency(
      id: 111,
      code: "RWF",
      currencyName: "Rwandan Franc",
      actualValue: 1,
    ),
    Currency(
      id: 112,
      code: "SHP",
      currencyName: "Saint Helena Pound",
      actualValue: 1,
    ),
    Currency(id: 113, code: "WST", currencyName: "Samoan Tala", actualValue: 1),
    Currency(
      id: 114,
      code: "STN",
      currencyName: "Sao Tome and Principe Dobra",
      actualValue: 1,
    ),
    Currency(id: 115, code: "SAR", currencyName: "Saudi Riyal", actualValue: 1),
    Currency(
      id: 116,
      code: "RSD",
      currencyName: "Serbian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 117,
      code: "SCR",
      currencyName: "Seychellois Rupee",
      actualValue: 1,
    ),
    Currency(
      id: 118,
      code: "SLL",
      currencyName: "Sierra Leonean Leone",
      actualValue: 1,
    ),
    Currency(
      id: 119,
      code: "SGD",
      currencyName: "Singapore Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 120,
      code: "SBD",
      currencyName: "Solomon Islands Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 121,
      code: "SOS",
      currencyName: "Somali Shilling",
      actualValue: 1,
    ),
    Currency(
      id: 122,
      code: "ZAR",
      currencyName: "South African Rand",
      actualValue: 1,
    ),
    Currency(
      id: 123,
      code: "KRW",
      currencyName: "South Korean Won",
      actualValue: 1,
    ),
    Currency(
      id: 124,
      code: "SSP",
      currencyName: "South Sudanese Pound",
      actualValue: 1,
    ),
    Currency(
      id: 125,
      code: "LKR",
      currencyName: "Sri Lankan Rupee",
      actualValue: 1,
    ),
    Currency(
      id: 126,
      code: "SDG",
      currencyName: "Sudanese Pound",
      actualValue: 1,
    ),
    Currency(
      id: 127,
      code: "SRD",
      currencyName: "Surinamese Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 128,
      code: "SZL",
      currencyName: "Swazi Lilangeni",
      actualValue: 1,
    ),
    Currency(
      id: 129,
      code: "SEK",
      currencyName: "Swedish Krona",
      actualValue: 1,
    ),
    Currency(id: 130, code: "CHF", currencyName: "Swiss Franc", actualValue: 1),
    Currency(
      id: 131,
      code: "SYP",
      currencyName: "Syrian Pound",
      actualValue: 1,
    ),
    Currency(
      id: 132,
      code: "TJS",
      currencyName: "Tajikistani Somoni",
      actualValue: 1,
    ),
    Currency(
      id: 133,
      code: "TZS",
      currencyName: "Tanzanian Shilling",
      actualValue: 1,
    ),
    Currency(id: 134, code: "THB", currencyName: "Thai Baht", actualValue: 1),
    Currency(
      id: 135,
      code: "TOP",
      currencyName: "Tongan Pa'anga",
      actualValue: 1,
    ),
    Currency(
      id: 136,
      code: "TTD",
      currencyName: "Trinidad and Tobago Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 137,
      code: "TND",
      currencyName: "Tunisian Dinar",
      actualValue: 1,
    ),
    Currency(
      id: 138,
      code: "TRY",
      currencyName: "Turkish Lira",
      actualValue: 1,
    ),
    Currency(
      id: 139,
      code: "TMT",
      currencyName: "Turkmenistani Manat",
      actualValue: 1,
    ),
    Currency(
      id: 140,
      code: "UGX",
      currencyName: "Ugandan Shilling",
      actualValue: 1,
    ),
    Currency(
      id: 141,
      code: "UAH",
      currencyName: "Ukrainian Hryvnia",
      actualValue: 1,
    ),
    Currency(
      id: 142,
      code: "AED",
      currencyName: "United Arab Emirates Dirham",
      actualValue: 1,
    ),
    Currency(
      id: 143,
      code: "GBP",
      currencyName: "United Kingdom Pound Sterling",
      actualValue: 1,
    ),
    Currency(
      id: 144,
      code: "USD",
      currencyName: "United States Dollar",
      actualValue: 1,
    ),
    Currency(
      id: 145,
      code: "UYU",
      currencyName: "Uruguayan Peso",
      actualValue: 1,
    ),
    Currency(
      id: 146,
      code: "UZS",
      currencyName: "Uzbekistani Som",
      actualValue: 1,
    ),
    Currency(
      id: 147,
      code: "VUV",
      currencyName: "Vanuatu Vatu",
      actualValue: 1,
    ),
    Currency(
      id: 148,
      code: "VES",
      currencyName: "Venezuelan Bolívar Soberano",
      actualValue: 1,
    ),
    Currency(
      id: 149,
      code: "VND",
      currencyName: "Vietnamese Dong",
      actualValue: 1,
    ),
    Currency(
      id: 150,
      code: "XOF",
      currencyName: "West African CFA Franc",
      actualValue: 1,
    ),
    Currency(id: 151, code: "YER", currencyName: "Yemeni Rial", actualValue: 1),
    Currency(
      id: 152,
      code: "ZMW",
      currencyName: "Zambian Kwacha",
      actualValue: 1,
    ),
    Currency(
      id: 153,
      code: "ZWL",
      currencyName: "Zimbabwean Dollar",
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
        return allCurrencies[144];
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
