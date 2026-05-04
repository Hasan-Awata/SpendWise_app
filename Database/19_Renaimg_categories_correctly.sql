-- 1. Delete all child records that reference CategoryID
DELETE FROM [Ledger].[Transactions];
DELETE FROM [Ledger].[Expenses];
DELETE FROM [Planning].[Budgets];
DELETE FROM [Planning].[FixedExpenses];

-- 2. Now SQL Server will let you empty the Categories table!
DELETE FROM [Config].[Categories];

-- 3. Insert your new categories here...
SET IDENTITY_INSERT [Config].[Categories] ON;

INSERT INTO [Config].[Categories] (CategoryID, Name, Priority)
VALUES 
    (1, 'Essentials', 1),
    (2, 'Secondaries', 2),
    (3, 'Luxuries', 3),
    (4, 'Savings', 4);
GO

SET IDENTITY_INSERT [Config].[Categories] OFF;
