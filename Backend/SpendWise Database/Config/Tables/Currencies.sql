CREATE TABLE [Config].[Currencies] (
    [CurrencyID]   INT           IDENTITY (1, 1) NOT NULL,
    [CurrencyName] NVARCHAR (50) NOT NULL,
    [CurrencyCode] CHAR (3)      NOT NULL,
    PRIMARY KEY CLUSTERED ([CurrencyID] ASC),
    CONSTRAINT [UQ_Currencies_Name] UNIQUE NONCLUSTERED ([CurrencyName] ASC)
);

