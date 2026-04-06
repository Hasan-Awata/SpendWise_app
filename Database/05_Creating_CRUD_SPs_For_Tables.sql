USE SpendWiseDB;
GO

-- =============================================
-- 1. Create (Insert User)
-- =============================================
CREATE PROCEDURE usr.sp_CreateUser
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255),
    @NewUserID INT OUTPUT -- إرجاع الـ ID الجديد
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO usr.Users (FirstName, LastName, Username, Password)
    VALUES (@FirstName, @LastName, @Username, @Password);
    
    SET @NewUserID = SCOPE_IDENTITY();
END
GO

-- =============================================
-- 2. Read (Get User By ID)
-- =============================================
CREATE PROCEDURE usr.sp_GetUserByID
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, FirstName, LastName, Username, Password 
    FROM usr.Users 
    WHERE UserID = @UserID;
END
GO

-- =============================================
-- 3. Update (Update User Info)
-- =============================================
CREATE PROCEDURE usr.sp_UpdateUser
    @UserID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE usr.Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        Password = @Password
    WHERE UserID = @UserID;
END
GO

-- =============================================
-- 4. Delete (Delete User)
-- =============================================
CREATE PROCEDURE usr.sp_DeleteUser
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- ملاحظة: في الأنظمة الحقيقية نفضل الـ Soft Delete (تغيير حالة IsActive) بدلاً من الحذف النهائي
    DELETE FROM usr.Users WHERE UserID = @UserID;
END
GO

-- =============================================
-- 1. Create (Insert Transaction)
-- =============================================
CREATE PROCEDURE fin.sp_CreateTransaction
    @UserID INT,
    @WalletID INT,
    @Amount DECIMAL(18,2),
    @TransactionType INT,
    @Description NVARCHAR(255),
    @CategoryID INT = NULL,
    @TagID INT = NULL,
    @GoalID INT = NULL,
    @ObligationID INT = NULL,
    @DebtID INT = NULL,
    @WorkID INT = NULL,
    @ExpenseID INT = NULL,
    @NewTransactionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO fin.Transactions 
        (UserID, WalletID, Amount, TransactionDate, TransactionType, Description, CategoryID, TagID, GoalID, ObligationID, DebtID, WorkID, ExpenseID)
    VALUES 
        (@UserID, @WalletID, @Amount, GETDATE(), @TransactionType, @Description, @CategoryID, @TagID, @GoalID, @ObligationID, @DebtID, @WorkID, @ExpenseID);
    
    SET @NewTransactionID = SCOPE_IDENTITY();
END
GO

-- =============================================
-- 2. Read (Get Transaction By ID)
-- =============================================
CREATE PROCEDURE fin.sp_GetTransactionByID
    @TransactionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM fin.Transactions WHERE TransactionID = @TransactionID;
END
GO

-- =============================================
-- 3. Update (Update Transaction)
-- =============================================
CREATE PROCEDURE fin.sp_UpdateTransaction
    @TransactionID INT,
    @Amount DECIMAL(18,2),
    @TransactionType INT,
    @Description NVARCHAR(255),
    @CategoryID INT = NULL,
    @TagID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- غالباً لا نسمح بتعديل الـ UserID والـ WalletID والمحاور الأساسية بعد إنشائها
    UPDATE fin.Transactions
    SET Amount = @Amount,
        TransactionType = @TransactionType,
        Description = @Description,
        CategoryID = @CategoryID,
        TagID = @TagID
    WHERE TransactionID = @TransactionID;
END
GO

-- =============================================
-- 4. Delete (Delete Transaction)
-- =============================================
CREATE PROCEDURE fin.sp_DeleteTransaction
    @TransactionID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM fin.Transactions WHERE TransactionID = @TransactionID;
END
GO

USE SpendWiseDB;
GO

-- ==============================================================================
-- سكيما الإعدادات (cfg): Currencies, Categories, Tags
-- ==============================================================================

-- --- Currencies ---
CREATE PROCEDURE cfg.sp_CreateCurrency @CurrencyName NVARCHAR(50), @ActualValue DECIMAL(18,6), @NewCurrencyID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO cfg.Currencies (CurrencyName, ActualValue) VALUES (@CurrencyName, @ActualValue); SET @NewCurrencyID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE cfg.sp_GetCurrencyByID @CurrencyID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM cfg.Currencies WHERE CurrencyID = @CurrencyID; END;
GO
CREATE PROCEDURE cfg.sp_UpdateCurrency @CurrencyID INT, @CurrencyName NVARCHAR(50), @ActualValue DECIMAL(18,6) AS
BEGIN SET NOCOUNT ON; UPDATE cfg.Currencies SET CurrencyName = @CurrencyName, ActualValue = @ActualValue WHERE CurrencyID = @CurrencyID; END;
GO
CREATE PROCEDURE cfg.sp_DeleteCurrency @CurrencyID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM cfg.Currencies WHERE CurrencyID = @CurrencyID; END;
GO

-- --- Categories ---
CREATE PROCEDURE cfg.sp_CreateCategory @Name NVARCHAR(100), @Priority INT, @NewCategoryID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO cfg.Categories (Name, Priority) VALUES (@Name, @Priority); SET @NewCategoryID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE cfg.sp_GetCategoryByID @CategoryID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM cfg.Categories WHERE CategoryID = @CategoryID; END;
GO
CREATE PROCEDURE cfg.sp_UpdateCategory @CategoryID INT, @Name NVARCHAR(100), @Priority INT AS
BEGIN SET NOCOUNT ON; UPDATE cfg.Categories SET Name = @Name, Priority = @Priority WHERE CategoryID = @CategoryID; END;
GO
CREATE PROCEDURE cfg.sp_DeleteCategory @CategoryID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM cfg.Categories WHERE CategoryID = @CategoryID; END;
GO

-- --- Tags ---
CREATE PROCEDURE cfg.sp_CreateTag @UserID INT, @Name NVARCHAR(100), @NewTagID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO cfg.Tags (UserID, Name) VALUES (@UserID, @Name); SET @NewTagID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE cfg.sp_GetTagByID @TagID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM cfg.Tags WHERE TagID = @TagID; END;
GO
CREATE PROCEDURE cfg.sp_UpdateTag @TagID INT, @Name NVARCHAR(100) AS
BEGIN SET NOCOUNT ON; UPDATE cfg.Tags SET Name = @Name WHERE TagID = @TagID; END;
GO
CREATE PROCEDURE cfg.sp_DeleteTag @TagID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM cfg.Tags WHERE TagID = @TagID; END;
GO


-- ==============================================================================
-- سكيما المالية (fin): Wallets, SavedWallets, SharedDebts, Expenses
-- ==============================================================================

-- --- Wallets ---
CREATE PROCEDURE fin.sp_CreateWallet @UserID INT, @CurrencyID INT, @Balance DECIMAL(18,2), @NewWalletID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO fin.Wallets (UserID, CurrencyID, Balance) VALUES (@UserID, @CurrencyID, @Balance); SET @NewWalletID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE fin.sp_GetWalletByID @WalletID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM fin.Wallets WHERE WalletID = @WalletID; END;
GO
CREATE PROCEDURE fin.sp_UpdateWalletBalance @WalletID INT, @Balance DECIMAL(18,2) AS
BEGIN SET NOCOUNT ON; UPDATE fin.Wallets SET Balance = @Balance WHERE WalletID = @WalletID; END;
GO
CREATE PROCEDURE fin.sp_DeleteWallet @WalletID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM fin.Wallets WHERE WalletID = @WalletID; END;
GO

-- --- SavedWallets ---
CREATE PROCEDURE fin.sp_CreateSavedWallet @WalletID INT, @Balance DECIMAL(18,2), @NewSavedWalletID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO fin.SavedWallets (WalletID, Balance) VALUES (@WalletID, @Balance); SET @NewSavedWalletID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE fin.sp_GetSavedWalletByID @SavedWalletID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM fin.SavedWallets WHERE SavedWalletID = @SavedWalletID; END;
GO
CREATE PROCEDURE fin.sp_UpdateSavedWallet @SavedWalletID INT, @Balance DECIMAL(18,2) AS
BEGIN SET NOCOUNT ON; UPDATE fin.SavedWallets SET Balance = @Balance WHERE SavedWalletID = @SavedWalletID; END;
GO
CREATE PROCEDURE fin.sp_DeleteSavedWallet @SavedWalletID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM fin.SavedWallets WHERE SavedWalletID = @SavedWalletID; END;
GO

-- --- SharedDebts ---
CREATE PROCEDURE fin.sp_CreateSharedDebt @CreditorID INT, @DebtorID INT, @Amount DECIMAL(18,2), @Title NVARCHAR(255), @Status NVARCHAR(50), @DueDate DATETIME, @NewDebtID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO fin.SharedDebts (CreditorID, DebtorID, Amount, Title, Status, CreatedAt, DueDate) VALUES (@CreditorID, @DebtorID, @Amount, @Title, @Status, GETDATE(), @DueDate); SET @NewDebtID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE fin.sp_GetSharedDebtByID @DebtID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM fin.SharedDebts WHERE DebtID = @DebtID; END;
GO
CREATE PROCEDURE fin.sp_UpdateSharedDebt @DebtID INT, @Amount DECIMAL(18,2), @Title NVARCHAR(255), @Status NVARCHAR(50), @DueDate DATETIME AS
BEGIN SET NOCOUNT ON; UPDATE fin.SharedDebts SET Amount = @Amount, Title = @Title, Status = @Status, DueDate = @DueDate WHERE DebtID = @DebtID; END;
GO
CREATE PROCEDURE fin.sp_DeleteSharedDebt @DebtID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM fin.SharedDebts WHERE DebtID = @DebtID; END;
GO

-- --- Expenses (المصاريف المستقلة) ---
CREATE PROCEDURE fin.sp_CreateExpense @UserID INT, @Amount DECIMAL(18,2), @NewExpenseID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO fin.Expenses (UserID, Amount) VALUES (@UserID, @Amount); SET @NewExpenseID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE fin.sp_GetExpenseByID @ExpenseID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM fin.Expenses WHERE ExpenseID = @ExpenseID; END;
GO
CREATE PROCEDURE fin.sp_UpdateExpense @ExpenseID INT, @Amount DECIMAL(18,2) AS
BEGIN SET NOCOUNT ON; UPDATE fin.Expenses SET Amount = @Amount WHERE ExpenseID = @ExpenseID; END;
GO
CREATE PROCEDURE fin.sp_DeleteExpense @ExpenseID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM fin.Expenses WHERE ExpenseID = @ExpenseID; END;
GO


-- ==============================================================================
-- سكيما التخطيط (pln): Budgets, SavingsGoals, FixedObligations, Works
-- ==============================================================================

-- --- Budgets ---
CREATE PROCEDURE pln.sp_CreateBudget @UserID INT, @CategoryID INT, @LimitAmount DECIMAL(18,2), @Percentage DECIMAL(5,2), @StartDate DATE, @EndDate DATE, @NewBudgetID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO pln.Budgets (UserID, CategoryID, LimitAmount, Percentage, StartDate, EndDate) VALUES (@UserID, @CategoryID, @LimitAmount, @Percentage, @StartDate, @EndDate); SET @NewBudgetID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE pln.sp_GetBudgetByID @BudgetID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM pln.Budgets WHERE BudgetID = @BudgetID; END;
GO
CREATE PROCEDURE pln.sp_UpdateBudget @BudgetID INT, @LimitAmount DECIMAL(18,2), @Percentage DECIMAL(5,2), @StartDate DATE, @EndDate DATE AS
BEGIN SET NOCOUNT ON; UPDATE pln.Budgets SET LimitAmount = @LimitAmount, Percentage = @Percentage, StartDate = @StartDate, EndDate = @EndDate WHERE BudgetID = @BudgetID; END;
GO
CREATE PROCEDURE pln.sp_DeleteBudget @BudgetID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM pln.Budgets WHERE BudgetID = @BudgetID; END;
GO

-- --- SavingsGoals ---
CREATE PROCEDURE pln.sp_CreateSavingsGoal @UserID INT, @Title NVARCHAR(255), @TargetAmount DECIMAL(18,2), @CurrentAmount DECIMAL(18,2), @DeadlineDate DATE, @NewGoalID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO pln.SavingsGoals (UserID, Title, TargetAmount, CurrentAmount, DeadlineDate) VALUES (@UserID, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate); SET @NewGoalID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE pln.sp_GetSavingsGoalByID @GoalID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM pln.SavingsGoals WHERE GoalID = @GoalID; END;
GO
CREATE PROCEDURE pln.sp_UpdateSavingsGoal @GoalID INT, @Title NVARCHAR(255), @TargetAmount DECIMAL(18,2), @CurrentAmount DECIMAL(18,2), @DeadlineDate DATE AS
BEGIN SET NOCOUNT ON; UPDATE pln.SavingsGoals SET Title = @Title, TargetAmount = @TargetAmount, CurrentAmount = @CurrentAmount, DeadlineDate = @DeadlineDate WHERE GoalID = @GoalID; END;
GO
CREATE PROCEDURE pln.sp_DeleteSavingsGoal @GoalID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM pln.SavingsGoals WHERE GoalID = @GoalID; END;
GO

-- --- FixedObligations ---
CREATE PROCEDURE pln.sp_CreateFixedObligation @UserID INT, @CategoryID INT, @Title NVARCHAR(255), @Amount DECIMAL(18,2), @DueDate DATE, @IsActive BIT, @NewObligationID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO pln.FixedObligations (UserID, CategoryID, Title, Amount, DueDate, IsActive) VALUES (@UserID, @CategoryID, @Title, @Amount, @DueDate, @IsActive); SET @NewObligationID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE pln.sp_GetFixedObligationByID @ObligationID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM pln.FixedObligations WHERE ObligationID = @ObligationID; END;
GO
CREATE PROCEDURE pln.sp_UpdateFixedObligation @ObligationID INT, @Title NVARCHAR(255), @Amount DECIMAL(18,2), @DueDate DATE, @IsActive BIT AS
BEGIN SET NOCOUNT ON; UPDATE pln.FixedObligations SET Title = @Title, Amount = @Amount, DueDate = @DueDate, IsActive = @IsActive WHERE ObligationID = @ObligationID; END;
GO
CREATE PROCEDURE pln.sp_DeleteFixedObligation @ObligationID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM pln.FixedObligations WHERE ObligationID = @ObligationID; END;
GO

-- --- Works (الأعمال) ---
CREATE PROCEDURE pln.sp_CreateWork @UserID INT, @TagID INT, @Title NVARCHAR(255), @Amount DECIMAL(18,2), @IsMonthly BIT, @Days INT, @LastTime DATETIME, @NewWorkID INT OUTPUT AS
BEGIN SET NOCOUNT ON; INSERT INTO pln.Works (UserID, TagID, Title, Amount, IsMonthly, Days, LastTime) VALUES (@UserID, @TagID, @Title, @Amount, @IsMonthly, @Days, @LastTime); SET @NewWorkID = SCOPE_IDENTITY(); END;
GO
CREATE PROCEDURE pln.sp_GetWorkByID @WorkID INT AS
BEGIN SET NOCOUNT ON; SELECT * FROM pln.Works WHERE WorkID = @WorkID; END;
GO
CREATE PROCEDURE pln.sp_UpdateWork @WorkID INT, @TagID INT, @Title NVARCHAR(255), @Amount DECIMAL(18,2), @IsMonthly BIT, @Days INT, @LastTime DATETIME AS
BEGIN SET NOCOUNT ON; UPDATE pln.Works SET TagID = @TagID, Title = @Title, Amount = @Amount, IsMonthly = @IsMonthly, Days = @Days, LastTime = @LastTime WHERE WorkID = @WorkID; END;
GO
CREATE PROCEDURE pln.sp_DeleteWork @WorkID INT AS
BEGIN SET NOCOUNT ON; DELETE FROM pln.Works WHERE WorkID = @WorkID; END;
GO