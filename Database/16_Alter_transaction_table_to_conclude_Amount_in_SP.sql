USE SpendWiseDB;
GO

ALTER TABLE [Ledger].[Transactions]
ADD AmountInSp DECIMAL(18,2) NOT NULL DEFAULT 0.00;