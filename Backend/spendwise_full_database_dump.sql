=========================================
 SPENDWISE DATABASE FULL DUMP
=========================================

-- =========================================
-- TABLES 
-- =========================================

CREATE TABLE [Banking].[Wallets] (
    [WalletID] int NOT NULL,
    [UserID] int NOT NULL,
    [CurrencyID] int NOT NULL,
    [Balance] decimal NOT NULL,
    [IsSaved] bit NOT NULL
);
GO

CREATE TABLE [Config].[Categories] (
    [CategoryID] int NOT NULL,
    [Name] nvarchar(100) NOT NULL,
    [Priority] int NOT NULL
);
GO

CREATE TABLE [Config].[Currencies] (
    [CurrencyID] int NOT NULL,
    [CurrencyName] nvarchar(50) NOT NULL,
    [CurrencyCode] char(3) NOT NULL
);
GO

CREATE TABLE [Config].[Tags] (
    [TagID] int NOT NULL,
    [UserID] int NOT NULL,
    [Name] nvarchar(100) NOT NULL
);
GO

CREATE TABLE [Identity].[Users] (
    [UserID] int NOT NULL,
    [FirstName] nvarchar(100) NOT NULL,
    [LastName] nvarchar(100) NOT NULL,
    [Username] nvarchar(100) NOT NULL,
    [Password] nvarchar(255) NOT NULL,
    [RefreshToken] nvarchar(255) NULL,
    [RefreshTokenExpiryTime] datetime NULL
);
GO

CREATE TABLE [Ledger].[Expenses] (
    [ExpenseID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(255) NULL,
    [TagID] int NULL,
    [CategoryID] int NOT NULL,
    [WalletID] int NOT NULL,
    [Products] nvarchar(MAX) NOT NULL,
    [Amount] decimal NOT NULL,
    [Date] datetime NOT NULL
);
GO

CREATE TABLE [Ledger].[Incomes] (
    [IncomeID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(255) NOT NULL,
    [TagID] int NULL,
    [WalletID] int NOT NULL,
    [Amount] decimal NOT NULL,
    [Date] datetime NOT NULL
);
GO

CREATE TABLE [Ledger].[Transactions] (
    [TransactionID] int NOT NULL,
    [UserID] int NOT NULL,
    [WalletID] int NOT NULL,
    [CategoryID] int NULL,
    [TagID] int NULL,
    [GoalID] int NULL,
    [FixedExpenseID] int NULL,
    [DebtID] int NULL,
    [FixedIncomeID] int NULL,
    [Title] nvarchar(255) NOT NULL,
    [Amount] decimal NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [TransactionType] int NOT NULL,
    [Description] nvarchar(MAX) NULL,
    [AmountInSp] decimal NOT NULL
);
GO

CREATE TABLE [Planning].[Budgets] (
    [BudgetID] int NOT NULL,
    [UserID] int NOT NULL,
    [CategoryID] int NOT NULL,
    [PercentageLimit] decimal NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    [IsActive] bit NOT NULL
);
GO

CREATE TABLE [Planning].[FixedExpenses] (
    [FixedExpenseID] int NOT NULL,
    [UserID] int NOT NULL,
    [CategoryID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Amount] decimal NOT NULL,
    [DueDate] date NOT NULL,
    [IsActive] bit NOT NULL
);
GO

CREATE TABLE [Planning].[FixedIncomes] (
    [FixedIncomeID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Amount] decimal NOT NULL,
    [IsMonthly] bit NOT NULL,
    [IsActive] bit NOT NULL,
    [Days] int NULL,
    [LastTime] datetime NULL
);
GO

CREATE TABLE [Planning].[SavingsGoals] (
    [GoalID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [TargetAmount] decimal NOT NULL,
    [CurrentAmount] decimal NOT NULL,
    [DeadlineDate] date NULL,
    [IsAchieved] bit NOT NULL,
    [CurrencyID] int NOT NULL
);
GO

CREATE TABLE [Planning].[SharedDebts] (
    [DebtID] int NOT NULL,
    [CreditorID] int NULL,
    [DebtorID] int NULL,
    [Amount] decimal NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Status] nvarchar(50) NOT NULL,
    [CreatedAt] datetime NOT NULL,
    [DueDate] datetime NULL,
    [CreditorWalletID] int NULL,
    [DebtorWalletID] int NULL,
    [PaidAmount] decimal NOT NULL
);
GO

