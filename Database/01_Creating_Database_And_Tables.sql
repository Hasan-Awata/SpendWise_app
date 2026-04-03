CREATE DATABASE SpendWiseDB;
GO

USE SpendWiseDB;
GO

-- 1. جدول المستخدمين (لا يعتمد على أي جدول)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Username NVARCHAR(100) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL
);

-- 2. جدول الفئات (لا يعتمد على أي جدول)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Priority INT NOT NULL
);

-- 3. جدول المحافظ (يعتمد على المستخدمين)
CREATE TABLE Wallets (
    WalletID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CurrencyName NVARCHAR(50) UNIQUE NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Wallets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 4. جدول المحافظ المحفوظة (يعتمد على المحافظ)
CREATE TABLE SavedWallets (
    SavedWalletID INT IDENTITY(1,1) PRIMARY KEY,
    WalletID INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_SavedWallets_Wallets FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID)
);

-- 5. جدول أهداف الادخار (يعتمد على المستخدمين)
CREATE TABLE SavingsGoals (
    GoalID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    TargetAmount DECIMAL(18,2) NOT NULL,
    CurrentAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    DeadlineDate DATE,
    CONSTRAINT FK_SavingsGoals_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 6. جدول الالتزامات الثابتة (يعتمد على المستخدمين)
CREATE TABLE FixedObligations (
    ObligationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    DueDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_FixedObligations_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 7. جدول الوسوم (يعتمد على المستخدمين والفئات)
CREATE TABLE Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Tags_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Tags_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 8. جدول الميزانيات (يعتمد على المستخدمين والفئات)
CREATE TABLE Budgets (
    BudgetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    LimitAmount DECIMAL(18,2) NOT NULL,
    Percentage DECIMAL(5,2) NOT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL,
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 9. جدول الديون والمصاريف المشتركة (يعتمد على المستخدمين مرتين)
CREATE TABLE SharedDebts (
    DebtID INT IDENTITY(1,1) PRIMARY KEY,
    CreditorID INT NOT NULL,
    DebtorID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Description NVARCHAR(255),
    Status NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    DueDate DATETIME,
    CONSTRAINT FK_SharedDebts_Creditor FOREIGN KEY (CreditorID) REFERENCES Users(UserID),
    CONSTRAINT FK_SharedDebts_Debtor FOREIGN KEY (DebtorID) REFERENCES Users(UserID)
);

-- 10. جدول العمليات (يعتمد على أغلب الجداول السابقة)
CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    DebtID INT NULL,
    TagID INT NOT NULL,          -- Nullable
    GoalID INT NULL,         -- Nullable
    ObligationID INT NULL,   -- Nullable
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    TransactionType INT NOT NULL,
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Transactions_SharedDebts FOREIGN KEY (DebtID) REFERENCES SharedDebts(DebtID),
    CONSTRAINT FK_Transactions_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID),
    CONSTRAINT FK_Transactions_SavingsGoals FOREIGN KEY (GoalID) REFERENCES SavingsGoals(GoalID),
    CONSTRAINT FK_Transactions_FixedObligations FOREIGN KEY (ObligationID) REFERENCES FixedObligations(ObligationID)
);
GO