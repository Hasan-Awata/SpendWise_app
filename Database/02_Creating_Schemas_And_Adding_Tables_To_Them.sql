USE SpendWiseDB;
GO

-- إنشاء السكيمات (Schemas)
CREATE SCHEMA usr;
GO
CREATE SCHEMA cfg;
GO
CREATE SCHEMA fin;
GO
CREATE SCHEMA pln;
GO

-- نقل الجداول للسكيمات الجديدة (إذا كنت بانيها مسبقاً على dbo)
ALTER SCHEMA usr TRANSFER dbo.Users;
ALTER SCHEMA cfg TRANSFER dbo.Categories;
ALTER SCHEMA cfg TRANSFER dbo.Tags;
ALTER SCHEMA fin TRANSFER dbo.Wallets;
ALTER SCHEMA fin TRANSFER dbo.SavedWallets;
ALTER SCHEMA fin TRANSFER dbo.SharedDebts;
ALTER SCHEMA fin TRANSFER dbo.Transactions;
ALTER SCHEMA pln TRANSFER dbo.SavingsGoals;
ALTER SCHEMA pln TRANSFER dbo.Budgets;
ALTER SCHEMA pln TRANSFER dbo.FixedObligations;
GO