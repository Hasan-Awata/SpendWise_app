using SpendWise.Domain.Entities;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace SpendWise.Domain.Constants
{
    public static class SupportedCurrencies
    {
        public const int SyrianPoundId = 1;

        public static readonly IReadOnlyDictionary<int, Currency> Map = new Dictionary<int, Currency>
        {
            { 1, new Currency(1, "SYP", "Syrian Pound") },
            { 2, new Currency(2, "USD", "United States Dollar") },
            { 3, new Currency(3, "EUR", "Euro") },
            { 4, new Currency(4, "TRY", "Turkish Lira") },
            { 5, new Currency(5, "SAR", "Saudi Riyal") },
            { 6, new Currency(6, "AED", "United Arab Emirates Dirham") },
            { 7, new Currency(7, "EGP", "Egyptian Pound") },
            { 8, new Currency(8, "LYD", "Libyan Dinar") },
            { 9, new Currency(9, "JOD", "Jordanian Dinar") },
            { 10, new Currency(10, "KWD", "Kuwaiti Dinar") },
            { 11, new Currency(11, "GBP", "British Pound Sterling") },
            { 12, new Currency(12, "QAR", "Qatari Riyal") },
            { 13, new Currency(13, "BHD", "Bahraini Dinar") },
            { 14, new Currency(14, "SEK", "Swedish Krona") },
            { 15, new Currency(15, "CAD", "Canadian Dollar") },
            { 16, new Currency(16, "OMR", "Omani Rial") },
            { 17, new Currency(17, "NOK", "Norwegian Krone") },
            { 18, new Currency(18, "DKK", "Danish Krone") },
            { 19, new Currency(19, "DZD", "Algerian Dinar") },
            { 20, new Currency(20, "MAD", "Moroccan Dirham") },
            { 21, new Currency(21, "TND", "Tunisian Dinar") },
            { 22, new Currency(22, "RUB", "Russian Ruble") },
            { 23, new Currency(23, "MYR", "Malaysian Ringgit") },
            { 24, new Currency(24, "BRL", "Brazilian Real") },
            { 25, new Currency(25, "NZD", "New Zealand Dollar") },
            { 26, new Currency(26, "CHF", "Swiss Franc") },
            { 27, new Currency(27, "AUD", "Australian Dollar") },
            { 28, new Currency(28, "ZAR", "South African Rand") },
            { 29, new Currency(29, "IQD", "Iraqi Dinar") },
            { 30, new Currency(30, "SGD", "Singapore Dollar") }
        }.AsReadOnly();

        /// <summary>
        /// Instantly retrieves a currency by its ID, or returns null if not found.
        /// </summary>
        public static Currency? GetById(int id)
        {
            return Map.TryGetValue(id, out var currency) ? currency : null;
        }

        /// <summary>
        /// Returns all currencies, useful for populating frontend dropdowns.
        /// </summary>
        public static IEnumerable<Currency> GetAll() => Map.Values;
    }
}