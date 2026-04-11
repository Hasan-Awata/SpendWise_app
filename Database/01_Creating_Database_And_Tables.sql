USE master;
GO

-- 1. Drop the existing database if it exists
IF DB_ID('SpendWiseDB') IS NOT NULL
BEGIN
    ALTER DATABASE SpendWiseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SpendWiseDB;
END
GO

-- 2. Create the new database
CREATE DATABASE SpendWiseDB;
GO

USE SpendWiseDB;
GO

-- ==========================================
-- 3. Create Independent Tables First
-- ==========================================

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    CONSTRAINT UQ_Users_Username UNIQUE (Username)
);

CREATE TABLE Currencies (
    CurrencyID INT IDENTITY(1,1) PRIMARY KEY,
    CurrencyName NVARCHAR(50) NOT NULL,
    ActualValue DECIMAL(18,4) NOT NULL,
    CONSTRAINT UQ_Currencies_Name UNIQUE (CurrencyName),
    CONSTRAINT CHK_Currencies_ActualValue CHECK (ActualValue >= 0)
);

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Priority INT NOT NULL
);

-- ==========================================
-- 4. Create Tables with 1st-Level Dependencies
-- ==========================================

CREATE TABLE Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Tags_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_Tags_UserName UNIQUE (UserID, Name)
);

CREATE TABLE Wallets (
    WalletID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CurrencyID INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Wallets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Wallets_Currencies FOREIGN KEY (CurrencyID) REFERENCES Currencies(CurrencyID),
    CONSTRAINT UQ_Wallets_UserCurrency UNIQUE (UserID, CurrencyID),
    CONSTRAINT CHK_Wallets_Balance CHECK (Balance >= 0)
);

CREATE TABLE SavingsGoals (
    GoalID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    TargetAmount DECIMAL(18,2) NOT NULL,
    CurrentAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    DeadlineDate DATE,
    IsAchieved BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_SavingsGoals_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CHK_SavingsGoals_TargetAmount CHECK (TargetAmount > 0),
    CONSTRAINT CHK_SavingsGoals_CurrentAmount CHECK (CurrentAmount >= 0)
);

CREATE TABLE Budgets (
    BudgetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    LimitAmount DECIMAL(18,2) NOT NULL,
    Percentage DECIMAL(5,2) CHECK (Percentage >= 0),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CHK_Budgets_LimitAmount CHECK (LimitAmount >= 0),
    CONSTRAINT CHK_Budgets_Dates CHECK (StartDate < EndDate)
);

CREATE TABLE SharedDebts (
    DebtID INT IDENTITY(1,1) PRIMARY KEY,
    CreditorID INT NOT NULL,
    DebtorID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    DueDate DATETIME,
    CONSTRAINT FK_SharedDebts_Creditor FOREIGN KEY (CreditorID) REFERENCES Users(UserID),
    CONSTRAINT FK_SharedDebts_Debtor FOREIGN KEY (DebtorID) REFERENCES Users(UserID),
    CONSTRAINT CHK_SharedDebts_Amount CHECK (Amount > 0)
);

CREATE TABLE FixedIncomes (
    FixedIncomeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    IsMonthly BIT NOT NULL DEFAULT 1,
    IsActive BIT NOT NULL DEFAULT 1,
    Days INT,
    LastTime DATETIME,
    CONSTRAINT FK_FixedIncomes_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT UQ_FixedIncomes_UserTitle UNIQUE (UserID, Title),
    CONSTRAINT CHK_FixedIncomes_Amount CHECK (Amount > 0)
);

CREATE TABLE FixedExpenses (
    FixedExpenseID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    DueDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_FixedExpenses_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_FixedExpenses_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_FixedExpenses_UserTitle UNIQUE (UserID, Title),
    CONSTRAINT CHK_FixedExpenses_Amount CHECK (Amount > 0)
);

-- ==========================================
-- 5. Create Tables with 2nd-Level Dependencies
-- ==========================================

CREATE TABLE SavedWallets (
    SavedWalletID INT IDENTITY(1,1) PRIMARY KEY,
    WalletID INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_SavedWallets_Wallets FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT CHK_SavedWallets_Balance CHECK (Balance >= 0)
);

CREATE TABLE Expenses (
    ExpenseID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    TagID INT,
    CategoryID INT NOT NULL,
    WalletID INT NOT NULL,
	Products NVARCHAR(1000) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Date DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Expenses_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Expenses_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID),
    CONSTRAINT FK_Expenses_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Expenses_Wallets FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT CHK_Expenses_Amount CHECK (Amount > 0)
);

CREATE TABLE Incomes (
    IncomeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    TagID INT,
    WalletID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Date DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Incomes_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Incomes_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID),
    CONSTRAINT FK_Incomes_Wallets FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT CHK_Incomes_Amount CHECK (Amount > 0)
);

-- ==========================================
-- 6. Create the Transactions Table
-- ==========================================

CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    WalletID INT NOT NULL,
    CategoryID INT,           
    TagID INT,                
    GoalID INT,               
    FixedExpenseID INT,
    DebtID INT,               
    FixedIncomeID INT,        
    ExpenseID INT,            
    IncomeID INT,             
    Title NVARCHAR(255) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    TransactionType INT NOT NULL,
    Description NVARCHAR(255),
    
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Transactions_Wallets FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Transactions_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID),
    CONSTRAINT FK_Transactions_SavingsGoals FOREIGN KEY (GoalID) REFERENCES SavingsGoals(GoalID),
    CONSTRAINT FK_Transactions_FixedExpenses FOREIGN KEY (FixedExpenseID) REFERENCES FixedExpenses(FixedExpenseID),
    CONSTRAINT FK_Transactions_SharedDebts FOREIGN KEY (DebtID) REFERENCES SharedDebts(DebtID),
    CONSTRAINT FK_Transactions_FixedIncomes FOREIGN KEY (FixedIncomeID) REFERENCES FixedIncomes(FixedIncomeID),
    CONSTRAINT FK_Transactions_Expenses FOREIGN KEY (ExpenseID) REFERENCES Expenses(ExpenseID),
    CONSTRAINT FK_Transactions_Incomes FOREIGN KEY (IncomeID) REFERENCES Incomes(IncomeID),
    CONSTRAINT CHK_Transactions_Amount CHECK (Amount > 0)
);
GO

-- ==========================================
-- 7. Create Conditional Unique Constraints (Filtered Indexes)
-- ==========================================

-- Savings goals are unique per user and title ONLY while not achieved (IsAchieved = 0)
CREATE UNIQUE NONCLUSTERED INDEX UQ_SavingsGoals_ActiveTitle 
ON SavingsGoals(UserID, Title)
WHERE IsAchieved = 0;
GO

-- Budgets are unique per user and category ONLY while the period is active (IsActive = 1)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Budgets_ActiveCategory 
ON Budgets(UserID, CategoryID)
WHERE IsActive = 1;
GO