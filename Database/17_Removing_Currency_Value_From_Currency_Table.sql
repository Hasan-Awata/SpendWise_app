USE SpendWiseDB;

ALTER TABLE Config.Currencies
DROP CONSTRAINT CHK_Currencies_ActualValue;

ALTER TABLE Config.Currencies
DROP COLUMN ActualValue;

-- =========================================================
-- 1. FLUSH 2ND-LEVEL DEPENDENCIES (Children of Wallets)
-- =========================================================
DELETE FROM [Ledger].[Transactions];
DELETE FROM [Ledger].[Expenses];
DELETE FROM [Ledger].[Incomes];

-- =========================================================
-- 2. FLUSH 1ST-LEVEL DEPENDENCIES (Wallets)
-- =========================================================
-- Now that Expenses/Incomes/Transactions are gone, Wallets are free to be deleted.
DELETE FROM [Banking].[Wallets];

-- =========================================================
-- 3. FLUSH CURRENCIES
-- =========================================================
-- Now that Wallets are gone, Currencies are free to be deleted.
DELETE FROM [Config].[Currencies];

-- Optional: Reset the internal ID counter so future inserts start cleanly
DBCC CHECKIDENT ('[Config].[Currencies]', RESEED, 0);

-- =========================================================
-- 4. SEED THE STRICT CURRENCY LIST
-- =========================================================
SET IDENTITY_INSERT [Config].[Currencies] ON;

INSERT INTO [Config].[Currencies] (CurrencyID, CurrencyCode, CurrencyName)
VALUES 
    (1, 'SYP', 'Syrian Pound'),
    (2, 'USD', 'United States Dollar'),
    (3, 'EUR', 'Euro'),
    (4, 'TRY', 'Turkish Lira'),
    (5, 'SAR', 'Saudi Riyal'),
    (6, 'AED', 'United Arab Emirates Dirham'),
    (7, 'EGP', 'Egyptian Pound'),
    (8, 'LYD', 'Libyan Dinar'),
    (9, 'JOD', 'Jordanian Dinar'),
    (10, 'KWD', 'Kuwaiti Dinar'),
    (11, 'GBP', 'British Pound Sterling'),
    (12, 'QAR', 'Qatari Riyal'),
    (13, 'BHD', 'Bahraini Dinar'),
    (14, 'SEK', 'Swedish Krona'),
    (15, 'CAD', 'Canadian Dollar'),
    (16, 'OMR', 'Omani Rial'),
    (17, 'NOK', 'Norwegian Krone'),
    (18, 'DKK', 'Danish Krone'),
    (19, 'DZD', 'Algerian Dinar'),
    (20, 'MAD', 'Moroccan Dirham'),
    (21, 'TND', 'Tunisian Dinar'),
    (22, 'RUB', 'Russian Ruble'),
    (23, 'MYR', 'Malaysian Ringgit'),
    (24, 'BRL', 'Brazilian Real'),
    (25, 'NZD', 'New Zealand Dollar'),
    (26, 'CHF', 'Swiss Franc'),
    (27, 'AUD', 'Australian Dollar'),
    (28, 'ZAR', 'South African Rand'),
    (29, 'IQD', 'Iraqi Dinar'),
    (30, 'SGD', 'Singapore Dollar');

SET IDENTITY_INSERT [Config].[Currencies] OFF;
GO