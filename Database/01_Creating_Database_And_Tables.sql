-- ==========================================
-- 0. إغلاق الاتصالات وحذف قاعدة البيانات القديمة بأمان
-- ==========================================
USE master;
GO

IF DB_ID('SpendWiseDB') IS NOT NULL
BEGIN
    ALTER DATABASE SpendWiseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SpendWiseDB;
END
GO

-- ==========================================
-- 1. إنشاء قاعدة البيانات الجديدة
-- ==========================================
CREATE DATABASE SpendWiseDB;
GO

USE SpendWiseDB;
GO

-- ==========================================
-- 2. إنشاء السكيمات (Schemas)
-- ==========================================
CREATE SCHEMA usr;
GO
CREATE SCHEMA cfg;
GO
CREATE SCHEMA fin;
GO
CREATE SCHEMA pln;
GO

-- ==========================================
-- 3. جداول الإعدادات والمستخدمين
-- ==========================================
CREATE TABLE usr.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    -- قيد: اليوزرنيم لا يتكرر
    CONSTRAINT UQ_Users_Username UNIQUE (Username) 
);

CREATE TABLE cfg.Currencies (
    CurrencyID INT IDENTITY(1,1) PRIMARY KEY,
    CurrencyName NVARCHAR(50) NOT NULL,
    ActualValue DECIMAL(18,6) NOT NULL,
    -- قيد: اسم العملة لا يتكرر
    CONSTRAINT UQ_Currencies_CurrencyName UNIQUE (CurrencyName)
);

CREATE TABLE cfg.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Priority INT NOT NULL,
    -- قيد: اسم الفئة لا يتكرر
    CONSTRAINT UQ_Categories_Name UNIQUE (Name)
);

CREATE TABLE cfg.Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Tags_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    -- قيد: التاغ لا يتكرر لنفس المستخدم
    CONSTRAINT UQ_Tags_User_Name UNIQUE (UserID, Name)
);

-- ==========================================
-- 4. جداول المحافظ
-- ==========================================
CREATE TABLE fin.Wallets (
    WalletID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CurrencyID INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Wallets_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_Wallets_Currencies FOREIGN KEY (CurrencyID) REFERENCES cfg.Currencies(CurrencyID),
    -- قيد: لا يمكن للمستخدم فتح محفظتين بنفس العملة
    CONSTRAINT UQ_Wallets_User_Currency UNIQUE (UserID, CurrencyID)
);

CREATE TABLE fin.SavedWallets (
    SavedWalletID INT IDENTITY(1,1) PRIMARY KEY,
    WalletID INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_SavedWallets_Wallets FOREIGN KEY (WalletID) REFERENCES fin.Wallets(WalletID)
);

-- ==========================================
-- 5. جداول التخطيط، الديون، والأعمال
-- ==========================================
CREATE TABLE pln.Budgets (
    BudgetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    LimitAmount DECIMAL(18,2) NOT NULL,
    Percentage DECIMAL(5,2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryID) REFERENCES cfg.Categories(CategoryID),
    -- قيود الميزانية
    CONSTRAINT CHK_Budgets_Dates CHECK (EndDate > StartDate),
    CONSTRAINT CHK_Budgets_Percentage CHECK (Percentage >= 0 AND Percentage <= 100),
    CONSTRAINT UQ_Budgets_User_Category_Dates UNIQUE (UserID, CategoryID, StartDate, EndDate)
);

CREATE TABLE pln.SavingsGoals (
    GoalID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    TargetAmount DECIMAL(18,2) NOT NULL,
    CurrentAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    DeadlineDate DATE,
    CONSTRAINT FK_SavingsGoals_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    -- قيد: المبلغ الحالي لا يتجاوز الهدف
    CONSTRAINT CHK_SavingsGoals_Amounts CHECK (CurrentAmount <= TargetAmount)
);

CREATE TABLE pln.FixedObligations (
    ObligationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    Title NVARCHAR(255) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    DueDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_FixedObligations_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_FixedObligations_Categories FOREIGN KEY (CategoryID) REFERENCES cfg.Categories(CategoryID)
);

CREATE TABLE fin.SharedDebts (
    DebtID INT IDENTITY(1,1) PRIMARY KEY,
    CreditorID INT NOT NULL,
    DebtorID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Title NVARCHAR(255), 
    Status NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    DueDate DATETIME,
    CONSTRAINT FK_SharedDebts_Creditor FOREIGN KEY (CreditorID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_SharedDebts_Debtor FOREIGN KEY (DebtorID) REFERENCES usr.Users(UserID)
);

CREATE TABLE pln.Works (
    WorkID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    TagID INT NULL,
    Title NVARCHAR(255) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    IsMonthly BIT NOT NULL DEFAULT 1,
    Days INT NULL, 
    LastTime DATETIME NULL,
    CONSTRAINT FK_Works_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_Works_Tags FOREIGN KEY (TagID) REFERENCES cfg.Tags(TagID)
);

CREATE TABLE fin.Expenses (
    ExpenseID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Expenses_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
	CONSTRAINT CHK_Expenses_Amount CHECK (Amount > 0)
);

-- ==========================================
-- 6. جدول العمليات المركزي (Transactions)
-- ==========================================
CREATE TABLE fin.Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    
    UserID INT NOT NULL,
    WalletID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    TransactionType INT NOT NULL, 
    Description NVARCHAR(255) NOT NULL,
    
    -- الحقول الاختيارية (Nullable)
    CategoryID INT NULL, 
    TagID INT NULL,      
    GoalID INT NULL,                 
    ObligationID INT NULL,           
    DebtID INT NULL,                 
    WorkID INT NULL,                 
    ExpenseID INT NULL,              

    -- العلاقات
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserID) REFERENCES usr.Users(UserID),
    CONSTRAINT FK_Transactions_Wallets FOREIGN KEY (WalletID) REFERENCES fin.Wallets(WalletID),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryID) REFERENCES cfg.Categories(CategoryID),
    CONSTRAINT FK_Transactions_Tags FOREIGN KEY (TagID) REFERENCES cfg.Tags(TagID),
    CONSTRAINT FK_Transactions_Goals FOREIGN KEY (GoalID) REFERENCES pln.SavingsGoals(GoalID),
    CONSTRAINT FK_Transactions_Obligations FOREIGN KEY (ObligationID) REFERENCES pln.FixedObligations(ObligationID),
    CONSTRAINT FK_Transactions_Debts FOREIGN KEY (DebtID) REFERENCES fin.SharedDebts(DebtID),
    CONSTRAINT FK_Transactions_Works FOREIGN KEY (WorkID) REFERENCES pln.Works(WorkID),
    CONSTRAINT FK_Transactions_Expenses FOREIGN KEY (ExpenseID) REFERENCES fin.Expenses(ExpenseID),
    
    -- قيد: يجب أن يكون المبلغ المدخل موجباً دائماً
    CONSTRAINT CHK_Transactions_Amount CHECK (Amount > 0)
);
GO