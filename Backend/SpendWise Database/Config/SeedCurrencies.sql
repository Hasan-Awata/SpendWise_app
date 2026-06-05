/* 1. Enable manual insertion of Identity IDs to match the C# Constant IDs */
SET IDENTITY_INSERT [Config].[Currencies] ON;

/* 2. Insert initial data */
MERGE INTO [Config].[Currencies] AS Target
USING (VALUES 
    (1, 'Syrian Pound', 'SYP'),
    (2, 'United States Dollar', 'USD'),
    (3, 'Euro', 'EUR'),
    (4, 'Turkish Lira', 'TRY'),
    (5, 'Saudi Riyal', 'SAR'),
    (6, 'United Arab Emirates Dirham', 'AED'),
    (7, 'Egyptian Pound', 'EGP'),
    (8, 'Libyan Dinar', 'LYD'),
    (9, 'Jordanian Dinar', 'JOD'),
    (10, 'Kuwaiti Dinar', 'KWD'),
    (11, 'British Pound Sterling', 'GBP'),
    (12, 'Qatari Riyal', 'QAR'),
    (13, 'Bahraini Dinar', 'BHD'),
    (14, 'Swedish Krona', 'SEK'),
    (15, 'Canadian Dollar', 'CAD'),
    (16, 'Omani Rial', 'OMR'),
    (17, 'Norwegian Krone', 'NOK'),
    (18, 'Danish Krone', 'DKK'),
    (19, 'Algerian Dinar', 'DZD'),
    (20, 'Moroccan Dirham', 'MAD'),
    (21, 'Tunisian Dinar', 'TND'),
    (22, 'Russian Ruble', 'RUB'),
    (23, 'Malaysian Ringgit', 'MYR'),
    (24, 'Brazilian Real', 'BRL'),
    (25, 'New Zealand Dollar', 'NZD'),
    (26, 'Swiss Franc', 'CHF'),
    (27, 'Australian Dollar', 'AUD'),
    (28, 'South African Rand', 'ZAR'),
    (29, 'Iraqi Dinar', 'IQD'),
    (30, 'Singapore Dollar', 'SGD')
) AS Source (CurrencyID, CurrencyName, CurrencyCode)
ON (Target.CurrencyID = Source.CurrencyID)
WHEN MATCHED THEN
    UPDATE SET 
        [CurrencyName] = Source.CurrencyName,
        [CurrencyCode] = Source.CurrencyCode
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([CurrencyID], [CurrencyName], [CurrencyCode])
    VALUES (Source.CurrencyID, Source.CurrencyName, Source.CurrencyCode);

/* 3. Disable manual insertion */
SET IDENTITY_INSERT [Config].[Currencies] OFF;