USE SpendWiseDB;
GO

-- ==========================================
-- 1. Create the Schemas
-- ==========================================
EXEC('CREATE SCHEMA [Identity]');
EXEC('CREATE SCHEMA [Config]');
EXEC('CREATE SCHEMA [Banking]');
EXEC('CREATE SCHEMA [Planning]');
EXEC('CREATE SCHEMA [Ledger]');
GO

-- ==========================================
-- 2. Move Tables to Schemas
-- ==========================================

-- Move to Identity
ALTER SCHEMA [Identity] TRANSFER dbo.Users;

-- Move to Config
ALTER SCHEMA [Config] TRANSFER dbo.Currencies;
ALTER SCHEMA [Config] TRANSFER dbo.Categories;
ALTER SCHEMA [Config] TRANSFER dbo.Tags;

-- Move to Banking
ALTER SCHEMA [Banking] TRANSFER dbo.Wallets;
ALTER SCHEMA [Banking] TRANSFER dbo.SavedWallets;

-- Move to Planning
ALTER SCHEMA [Planning] TRANSFER dbo.SavingsGoals;
ALTER SCHEMA [Planning] TRANSFER dbo.Budgets;
ALTER SCHEMA [Planning] TRANSFER dbo.SharedDebts;
ALTER SCHEMA [Planning] TRANSFER dbo.FixedIncomes;
ALTER SCHEMA [Planning] TRANSFER dbo.FixedExpenses;

-- Move to Ledger
ALTER SCHEMA [Ledger] TRANSFER dbo.Expenses;
ALTER SCHEMA [Ledger] TRANSFER dbo.Incomes;
ALTER SCHEMA [Ledger] TRANSFER dbo.Transactions;
GO

insert into [config].Categories(Name,Priority) values ('Essentials',1);
insert into [config].Categories(Name,Priority) values ('Secondaries',2);
insert into [config].Categories(Name,Priority) values ('Luxuries',3);
insert into [config].Categories(Name,Priority) values ('Savings',4);