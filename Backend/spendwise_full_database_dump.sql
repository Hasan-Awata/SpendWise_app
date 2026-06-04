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

CREATE TABLE [dbo].[__RefactorLog] (
    [OperationKey] uniqueidentifier NOT NULL
);
GO

CREATE TABLE [Identity].[Users] (
    [UserID] int NOT NULL,
    [FirstName] nvarchar(100) NOT NULL,
    [LastName] nvarchar(100) NOT NULL,
    [Username] nvarchar(100) NOT NULL,
    [Password] nvarchar(255) NOT NULL,
    [RefreshToken] nvarchar(255) NULL,
    [RefreshTokenExpiryTime] datetime NULL,
    [FcmToken] nvarchar(MAX) NULL
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
    [WalletId] int NOT NULL,
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

-- =========================================
-- STORED PROCEDURES 
-- =========================================

-- Schema: [Banking] | Procedure: [sp_AddWallet]

-- ==========================================
-- Add Wallet (Strict Currency Link)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        -- 1. Explicitly verify the CurrencyId exists before inserting
        -- (Optional, but provides a clean error message that your new SqlExceptionHandler can catch!)
        IF NOT EXISTS (SELECT 1 FROM [Config].Currencies WHERE CurrencyID = @CurrencyId)
        BEGIN
            ;THROW 50001, 'The specified Currency ID does not exist.', 1; 
        END

        -- 2. Create the Wallet using the directly provided CurrencyId
        INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance, IsSaved)
        VALUES (@UserId, @CurrencyId, @Balance, @IsSaved);
        
        DECLARE @NewWalletID INT = SCOPE_IDENTITY();

        COMMIT TRAN; -- Lock Released: Operation succeeded
        
        -- Return the new WalletID to C#
        SELECT @NewWalletID;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO

-- Schema: [Banking] | Procedure: [sp_DeleteWallet]

-- ==========================================
-- 5. Delete a Wallet
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_DeleteWallet]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    DELETE FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
    
    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetUserWallets]

-- ==========================================
-- 2. Get All Wallets for a User (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetUserWallets]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        WalletID, 
        Balance, 
        UserID, 
        IsSaved,
        CurrencyID
    FROM [Banking].Wallets
    WHERE UserID = @UserId;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetUserWalletsPair]
CREATE PROCEDURE [Banking].[sp_GetUserWalletsPair]
	@WalletId INT,
	@UserId	 INT
AS
BEGIN
SET NOCOUNT ON;

    SELECT 
        w2.WalletID,
        w2.UserId,
        w2.CurrencyID,
        w2.Balance,
        w2.IsSaved
    FROM [Banking].Wallets w1
    INNER JOIN [Banking].Wallets w2 ON w1.UserId = w2.UserId AND w1.CurrencyId = w2.CurrencyId
    WHERE w1.WalletID = @WalletId;
END;
GO

-- Schema: [Banking] | Procedure: [sp_GetWalletById]

-- ==========================================
-- 1. Get Wallet By ID (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetWalletById]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        WalletID, 
        Balance, 
        UserID, 
        IsSaved,
        CurrencyID
    FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetWalletsByCurrencyId]
CREATE PROCEDURE [Banking].[sp_GetWalletsByCurrencyId]
	@UserId		INT,
	@CurrencyId INT
AS
BEGIN
	SELECT * FROM [Banking].Wallets 
	WHERE UserID = @UserId AND CurrencyID = @CurrencyId;
END
GO

-- Schema: [Banking] | Procedure: [sp_UpdateWallet]

-- ==========================================
-- Update Wallet 
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_UpdateWallet]
    @WalletId INT,
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        -- Optional: Explicitly verify the CurrencyId exists before updating.
        -- (If you have a Foreign Key constraint on Wallets.CurrencyID, the database will handle this automatically!)
        IF NOT EXISTS (SELECT 1 FROM [Config].Currencies WHERE CurrencyID = @CurrencyId)
        BEGIN
            THROW 50001, 'The specified Currency ID does not exist.', 1; 
        END

        -- Update the Wallet using the directly provided CurrencyId
        UPDATE [Banking].Wallets
        SET CurrencyID = @CurrencyId,
            Balance = @Balance,
            IsSaved = @IsSaved
        WHERE WalletID = @WalletId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; -- Lock Released
        
        -- Return the number of rows affected
        SELECT @RowsAffected;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO

-- Schema: [Config] | Procedure: [sp_CreateTag]
-- ==========================================
-- 1. Create Tag
-- ==========================================
CREATE   PROCEDURE [Config].[sp_CreateTag]
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate tag names for this specific user
    IF EXISTS (SELECT 1 FROM [Config].Tags WHERE UserID = @UserID AND Name = @Name)
    BEGIN
        THROW 50004, 'A tag with this name already exists for your account.', 1;
    END

    INSERT INTO [Config].Tags (UserID, Name)
    VALUES (@UserID, @Name);

    -- Return the new ID on success
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- Schema: [Config] | Procedure: [sp_DeleteTag]

-- ==========================================
-- 3. Delete Tag (Secured)
-- ==========================================
CREATE   PROCEDURE [Config].[sp_DeleteTag]
    @TagID INT,
    @UserID INT -- Added IDOR Security
AS
BEGIN
    SET NOCOUNT ON;

    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    DELETE FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Config] | Procedure: [sp_GetTag]

-- ==========================================
-- 4. Get Tag By ID
-- ==========================================
CREATE   PROCEDURE [Config].[sp_GetTag]
    @TagID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;
END
GO

-- Schema: [Config] | Procedure: [sp_GetTags]

-- ==========================================
-- 5. Get All Tags By User
-- ==========================================
CREATE   PROCEDURE [Config].[sp_GetTags]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE UserID = @UserID;
END
GO

-- Schema: [Config] | Procedure: [sp_UpdateTag]

-- ==========================================
-- 2. Update Tag (Secured)
-- ==========================================
CREATE   PROCEDURE [Config].[sp_UpdateTag]
    @TagID INT,
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    UPDATE [Config].Tags
    SET Name = @Name
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [dbo] | Procedure: [sp_CheckSharedDebtExists]
CREATE PROCEDURE [dbo].[sp_CheckSharedDebtExists]
	@DebtID INT
AS
	IF EXISTS (SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID)
        SELECT 1;
    ELSE
        SELECT 0;
RETURN 0
GO

-- Schema: [dbo] | Procedure: [sp_GetSharedDebtsIHaveToPay]
CREATE PROCEDURE [dbo].[sp_GetSharedDebtsIHaveToPay]
	@UserId INT
AS
	SELECT * FROM [Planning].[SharedDebts] WHERE [DebtorID] = @UserId;
RETURN 0
GO

-- Schema: [dbo] | Procedure: [sp_GetSharedDebtsOwedToUser]
CREATE PROCEDURE [dbo].[sp_GetSharedDebtsOwedToUser]
	@UserId INT
AS
	SELECT * FROM [Planning].[SharedDebts] WHERE [CreditorID] = @UserId;
RETURN 0
GO

-- Schema: [Identity] | Procedure: [sp_AddUser]
CREATE PROCEDURE [Identity].[sp_AddUser]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Automatically rolls back if a runtime error occurs

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @CreatedUserId INT;
            DECLARE @Today DATE = CAST(GETDATE() AS DATE);
            DECLARE @EndOfMonth DATE = EOMONTH(GETDATE());

            -- 1. Create the user. 
            -- (Relies on a UNIQUE constraint on [Identity].Users(Username), no need for safety checks)
            INSERT INTO [Identity].Users (FirstName, LastName, Username, Password)
            VALUES (@FirstName, @LastName, @Username, @Password);
            
            SET @CreatedUserId = SCOPE_IDENTITY();

            -- 2. Insert initial wallets 
            INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance, IsSaved)
            VALUES 
                (@CreatedUserId, 1, 0, 0), -- Expenses wallet
                (@CreatedUserId, 1, 0, 1); -- Savings wallet

            -- 3. Insert Default Tags
            INSERT INTO [Config].Tags (UserID, Name)
            VALUES 
                (@CreatedUserId, 'General'),
                (@CreatedUserId, 'Groceries'),
                (@CreatedUserId, 'Bills');

            -- 4. Insert Default Budgeting plan (25/25/30/20)
            INSERT INTO [Planning].Budgets (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
            VALUES 
                (@CreatedUserId, 1, 25, @Today, @EndOfMonth, 1), -- Essentials
                (@CreatedUserId, 2, 25, @Today, @EndOfMonth, 1), -- Secondaries
                (@CreatedUserId, 3, 30, @Today, @EndOfMonth, 1), -- Luxuries
                (@CreatedUserId, 4, 20, @Today, @EndOfMonth, 1); -- Savings            
        COMMIT TRANSACTION;

        -- Return the ID for ExecuteScalar or output param usage
        SELECT @CreatedUserId;

    END TRY
    BEGIN CATCH
        -- Ensure the transaction is rolled back on error
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Schema: [Identity] | Procedure: [sp_CheckUsernameExists]

-- ==========================================
-- 4. Check if Username Exists (Optimized)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_CheckUsernameExists]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Returns a simple boolean (1 or 0) for C# to read via ExecuteScalarAsync
    IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        SELECT CAST(1 AS BIT);
    ELSE
        SELECT CAST(0 AS BIT);
END
GO

-- Schema: [Identity] | Procedure: [sp_GetUserById]

-- ==========================================
-- 3. Get User By ID (For Session Management)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password, RefreshToken, RefreshTokenExpiryTime
    FROM [Identity].Users
    WHERE UserID = @UserId;
END
GO

-- Schema: [Identity] | Procedure: [sp_GetUserByUsername]

-- ==========================================
-- 2. Get User By Username (For Login)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password, RefreshToken, RefreshTokenExpiryTime
    FROM [Identity].Users
    WHERE Username = @Username;
END
GO

-- Schema: [Identity] | Procedure: [sp_UpdateUserFcmToken]
CREATE PROCEDURE [Identity].[sp_UpdateUserFcmToken]
    @UserID INT,
    @FcmToken NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Attempt the update
        UPDATE [Identity].Users
        SET FcmToken = @FcmToken
        WHERE UserID = @UserID;

        -- Check how many rows were actually affected
        IF @@ROWCOUNT = 0
        BEGIN
            -- The query ran, but no user was found with that ID
            SELECT 
                CAST(0 AS BIT) AS IsSuccess
        END
        ELSE
        BEGIN
            -- Successfully updated the row
            SELECT 
                CAST(1 AS BIT) AS IsSuccess
        END
    END TRY
    BEGIN CATCH
        -- A fatal SQL error occurred
        SELECT 
            CAST(0 AS BIT) AS IsSuccess
    END CATCH
END
GO

-- Schema: [Identity] | Procedure: [sp_UpdateUserRefreshToken]
CREATE PROCEDURE [Identity].[sp_UpdateUserRefreshToken]
	@RefreshToken NVARCHAR (255) = NULL,
	@RefreshTokenExpiryTime DATETIME = NULL,
    @UserId INT
AS
BEGIN
    UPDATE [Identity].[Users]
    SET RefreshToken = @RefreshToken,
        RefreshTokenExpiryTime = @RefreshTokenExpiryTime
    WHERE UserID = @UserId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddExpenseUsingBothWallets]
-- ====================================================================
-- Add Expense, Transaction, and Deduct Balance across multiple wallets
-- ====================================================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseUsingBothWallets]
    -- Shared PARAMETERS
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @SavingWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, 
    @AmountInSp DECIMAL(18,2), 
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewExpenseID INT OUTPUT,
    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0; 

    BEGIN TRY
        BEGIN TRAN; 

        -- 1. UPDATE WALLETS FIRST (Strictly ordered by WalletID to prevent deadlocks)
        
        DECLARE @UpdatedRows INT = 0;

        IF @PrimaryWalletId < @SavingWalletId
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END

        -- If both wallets weren't updated, either they don't exist or the user doesn't own them
        IF @UpdatedRows < 2
        BEGIN
            ;THROW 50001, 'Wallet validation failed. Check ownership or existence.', 1;
        END

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@UserId, @PrimaryWalletId, @CategoryId, @TagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @Title, @Amount, @AmountInSp, @Date, @TransactionType, @Description);

        SET @NewExpenseID = SCOPE_IDENTITY();
        
        -- 3. Insert Expense
        INSERT INTO [Ledger].Expenses (ExpenseID ,UserID, Title, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@NewExpenseID, @UserId, @Title, @PrimaryWalletId, @TagId, @CategoryId, @Products, @Amount, @Date);

        -- 4. COMMIT TRANSACTION ASAP
        COMMIT TRAN; 

        -- 5. POST-TRANSACTION BUDGET CHECK
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddExpenseWithTransaction]
-- ==========================================
-- 3. Add Expense, Transaction, and Deduct Balance
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
   -- Shared PARAMETERS
    @UserId INT,
    @WalletId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, 
    @AmountInSp DECIMAL(18,2), 
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewExpenseID INT OUTPUT,
    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0; 

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@UserId, @WalletId, @CategoryId, @TagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @Title, @Amount, @AmountInSp, @Date, @TransactionType, @Description);

        SET @NewExpenseID = SCOPE_IDENTITY();
        
        -- 2. Insert Expense
        INSERT INTO [Ledger].Expenses (ExpenseID ,UserID, Title, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@NewExpenseID, @UserId, @Title, @WalletId, @TagId, @CategoryId, @Products, @Amount, @Date);
        


        -- 3. UPDATE WALLET BALANCE (DEDUCT FOR EXPENSE)
        UPDATE [Banking].Wallets
        SET Balance = Balance - @Amount
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 4. CALCULATE BUDGET STATUS USING CENTRALIZED FUNCTION
        -- The function is called before COMMIT so it includes the transaction just inserted.
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        COMMIT TRAN; 

        -- Return values for the application layer
        SELECT @NewExpenseID AS NewExpenseID, @IsOverLimit AS IsOverLimit;

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddIncomeWithTransaction]
CREATE PROCEDURE [Ledger].[sp_AddIncomeWithTransaction]
    -- Shared Parameters
    @UserId INT,
    @WalletId INT,
    @Amount DECIMAL(18,2),
    @IncomeDate DATETIME,
    @Title NVARCHAR(255),
    @TagId INT = NULL,

    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @AmountInSp DECIMAL(18,2) = 0,
    @TransactionType INT = 0, 
    @GoalId INT = NULL,
    @DebtId INT = NULL,
    @FixedIncomeId INT = NULL,
    @FixedExpenseId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewIncomeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS 
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 

        -- 2. INSERT INTO TRANSACTIONS FIRST
        -- This generates the Identity ID that the Income will inherit
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, TagID, Title, Amount, 
            AmountInSp, TransactionDate, TransactionType, 
            [Description], GoalID, DebtID, FixedIncomeID, FixedExpenseID
        )
        VALUES (
            @UserId, @WalletId, @TagId, @Title, @Amount, 
            @AmountInSp, @IncomeDate, @TransactionType, 
            @Description, @GoalId, @DebtId, @FixedIncomeId, @FixedExpenseId
        );
        
        -- Capture the ID generated by the Transactions table
        SET @NewIncomeID = SCOPE_IDENTITY();

        -- 3. INSERT INTO INCOMES SECOND
        -- Note: IncomeID is NOT an identity; we force it to match @NewIncomeID
        INSERT INTO [Ledger].[Incomes] (
            IncomeID, UserID, WalletID, TagID, 
            Title, Amount, [Date]
        )
        VALUES (
            @NewIncomeID, @UserId, @WalletId, @TagId, 
            @Title, @Amount, @IncomeDate
        );

        -- 4. UPDATE WALLET BALANCE (ADD FOR INCOME)
        UPDATE [Banking].[Wallets]
        SET Balance = Balance + @Amount
        WHERE WalletID = @WalletId AND UserID = @UserId;

        COMMIT TRAN; 

        -- Return the ID to the application
        SELECT @NewIncomeID AS NewIncomeID;

    END TRY
    BEGIN CATCH
        -- Ensure the entire operation is rolled back if ANY step fails
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_DeleteExpense]

-- ==========================================
-- 5. Delete Expense, Transaction, and Refund Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_DeleteExpense]
    @ExpenseId INT,
    @UserId INT -- Added for IDOR Security
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- STRICT SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @ActualOwnerId = UserID, @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END

        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Delete dependencies safely
        DELETE FROM [Ledger].Transactions WHERE TransactionID = @ExpenseId AND UserID = @UserId;
        -- DELETE FROM [Ledger].Expenses WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 2. Refund the money to the wallet since the expense was deleted
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Banking].Wallets 
            SET Balance = Balance + @AmountToRevert 
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_DeleteIncome]

-- ==========================================
-- 5. Delete Income, Transaction, and Revert Balance 
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT,
    @UserId INT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        -- 1. Capture the amount and wallet to revert (Ensuring ownership)
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @UserId; 

        IF @AmountToRevert IS NULL 
            THROW 50002, 'Income record was not found or access is denied.', 1;

        -- 2. Delete dependencies safely
        -- REMINDER: TransactionID == IncomeID
        DELETE FROM [Ledger].Transactions WHERE TransactionID = @IncomeId AND UserID = @UserId;
       -- DELETE FROM [Ledger].Incomes WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Subtract the money from the wallet since the income was deleted
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Banking].Wallets 
            SET Balance = Balance - @AmountToRevert 
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetExpense]
CREATE PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID, 
        e.UserID,
        e.Title,
        e.Amount, 
        e.Products, 
        e.[Date], 
        e.WalletID, 
        e.CategoryID, 
        e.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Expenses] e
    INNER JOIN [Ledger].[Transactions] t ON e.ExpenseID = t.TransactionID
    WHERE ExpenseID = @ExpenseId AND e.UserID = @UserId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetExpensesByUserPaged]

-- ==========================================
-- 2. Get Expenses By User Paged (Optimized: No Joins!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetExpensesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Expenses
    WHERE UserID = @UserId;

    SELECT 
        e.ExpenseID, 
        e.UserID,
        e.Title,
        e.Amount, 
        e.Products, 
        e.[Date], 
        e.WalletID, 
        e.CategoryID, 
        e.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Expenses] e
    INNER JOIN [Ledger].[Transactions] t ON e.ExpenseID = t.TransactionID
    WHERE e.UserID = @UserId
    ORDER BY Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetIncome]
-- ==========================================
-- 1. Get Income By ID 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IncomeID, 
        i.UserID,
        i.Title,
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Incomes] i
    INNER JOIN [Ledger].[Transactions] t ON i.IncomeID = t.TransactionID
    WHERE i.IncomeID = @IncomeID AND i.UserID = @UserID;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetIncomesByUserPaged]
-- ==========================================
-- 2. Get Incomes By User Paged (With Description)
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT,
    @TagId INT = NULL,
    @TransactionType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes i
    INNER JOIN [Ledger].Transactions t ON i.IncomeID = t.TransactionID
    WHERE i.UserID = @UserId
      AND (@TagId IS NULL OR i.TagID = @TagId)
      AND (@TransactionType IS NULL OR t.TransactionType = @TransactionType);

    -- Result Set 2: Paged Incomes with Transaction Details
    SELECT 
        i.IncomeID, 
        i.UserID, 
        i.Title, 
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].Incomes i
    INNER JOIN [Ledger].Transactions t ON i.IncomeID = t.TransactionID
    WHERE i.UserID = @UserId
      AND (@TagId IS NULL OR i.TagID = @TagId)
      AND (@TransactionType IS NULL OR t.TransactionType = @TransactionType)
    ORDER BY i.[Date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetProducts]

-- ==========================================
-- 6. Get Products JSON String
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetProducts]
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Products 
    FROM [Ledger].[Expenses] 
    WHERE ExpenseID = @ExpenseId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetTransactionsByUserPaged]
-- ==========================================
-- Get Transactions By User Paged 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetTransactionsByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT,
    @TagId INT = NULL,
    @CategoryId INT = NULL,
    @TransactionType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Transactions
    WHERE UserID = @UserId
      AND (@TagId IS NULL OR TagID = @TagId)
      AND (@CategoryId IS NULL OR CategoryID = @CategoryId)
      AND (@TransactionType IS NULL OR TransactionType = @TransactionType);

    -- Result Set 2: Paged Transactions with Transaction Details
    SELECT 
        TransactionID,
        UserID,
        Title,
        Description,
        Amount,
        AmountInSp,
        TransactionDate,
        TransactionType,
        WalletID,
        CategoryID,
        TagID,
        GoalID,
        FixedExpenseID,
        FixedIncomeID,
        DebtID

    FROM [Ledger].Transactions
    WHERE UserID = @UserId
      AND (@TagId IS NULL OR TagID = @TagId)
      AND (@CategoryId IS NULL OR CategoryID = @CategoryId)
      AND (@TransactionType IS NULL OR TransactionType = @TransactionType)
    ORDER BY [TransactionDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateExpenseUsingBothWallets]
CREATE PROCEDURE [Ledger].[sp_UpdateExpenseUsingBothWallets]
    @ExpenseId INT,
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1,
    @AmountInSp DECIMAL(18,2),
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0;

    BEGIN TRY
        -- ==========================================
        -- 1. STATE FETCH (Fetch historical state)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldPrimaryWalletId INT;
        
        SELECT 
            @ActualOwnerId = UserID, 
            @OldAmount = Amount, 
            @OldPrimaryWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        -- DYNAMIC LOOKUP: Find the new saving wallet paired with the new primary wallet
        DECLARE @NewSavingWalletId INT;
        SELECT @NewSavingWalletId = W2.WalletID
        FROM [Banking].Wallets W1
        JOIN [Banking].Wallets W2 ON W1.CurrencyID = W2.CurrencyID 
            AND W2.IsSaved = 1
            AND W2.UserID = @UserId
        WHERE W1.WalletID = @PrimaryWalletId;

        -- ==========================================
        -- 2. TRANSACTION EXECUTION
        -- ==========================================
        BEGIN TRAN; 

        -- Update Expense Table
        UPDATE [Ledger].Expenses
        SET WalletID = @PrimaryWalletId, 
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date,
            Title = @Title
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            -- Update Transaction Table
            UPDATE [Ledger].Transactions
            SET WalletID = @PrimaryWalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description,
                GoalID = @GoalId,
                FixedExpenseID = @FixedExpenseId,
                FixedIncomeID = @FixedIncomeId,
                DebtID = @DebtId
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- =========================================================
            -- 3. NET BALANCE MATH (Your Reversal Logic + New Deductions)
            -- =========================================================
            DECLARE @WalletAdjustments TABLE (
                WalletID INT,
                Modifier DECIMAL(18,2)
            );

            -- Step A: Full Refund to the Old Primary Wallet
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES (@OldPrimaryWalletId, @OldAmount);

            -- Step B: Apply New Deductions to New Wallets
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES 
            (@PrimaryWalletId, -@AmountFromPrimaryWallet),
            (@NewSavingWalletId, -@AmountFromSavingWallet);

            -- Process physical database updates grouped and in strict WalletID order.
            -- This cleanly handles cases where @OldPrimaryWalletId and @PrimaryWalletId 
            -- are the exact same row by combining them into one single atomic update.
            DECLARE @CurrentWalletID INT;
            DECLARE @CurrentModifier DECIMAL(18,2);

            DECLARE WalletCursor CURSOR LOCAL FAST_FORWARD FOR
                SELECT WalletID, SUM(Modifier) 
                FROM @WalletAdjustments 
                WHERE WalletID IS NOT NULL
                GROUP BY WalletID
                HAVING SUM(Modifier) <> 0 -- Skip if the net change is perfectly zero
                ORDER BY WalletID ASC;    -- Anti-deadlock sorting

            OPEN WalletCursor;
            FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @CurrentModifier
                WHERE WalletID = @CurrentWalletID AND UserID = @UserId;

                FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;
            END

            CLOSE WalletCursor;
            DEALLOCATE WalletCursor;
        END

        COMMIT TRAN; 

        -- 4. POST-TRANSACTION BUDGET EVALUATION
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateExpenseWithTransaction]

-- ==========================================
-- 4. Update Expense, Transaction, and Adjust Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
    @ExpenseId INT,
    @UserId INT,
    @WalletId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1,
    @AmountInSp DECIMAL(18,2),
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS (IDOR)
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- EXPENSE SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @ActualOwnerId = UserID, @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 

        -- 1. Update Expense
        UPDATE [Ledger].Expenses
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- Update Transaction and Wallets (Only if expense exists)
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Ledger].Transactions
            SET WalletID = @WalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- Balance Math logic 
            IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @OldAmount - @Amount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            ELSE
            BEGIN
                UPDATE [Banking].Wallets SET Balance = Balance + @OldAmount WHERE WalletID = @OldWalletId AND UserID = @UserId;
                UPDATE [Banking].Wallets SET Balance = Balance - @Amount WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        -- Update the output variable using the function
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        COMMIT TRAN; 

        -- Return as result set for the Reader
        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateIncomeWithTransaction]
CREATE PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT, -- This is also the TransactionID
    @UserId INT,
    @WalletId INT, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 0,
    @AmountInSp DECIMAL(18,2), 
    @CategoryId INT = NULL,
    @GoalId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS 
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END


        BEGIN TRAN; 

        -- 2. FETCH OLD DATA FOR RE-BALANCING
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        -- fetch the old values
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;

        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;

        -- 3. UPDATE THE INCOME TABLE
        UPDATE [Ledger].Incomes
        SET WalletID = @WalletId,
            TagID = @TagId,
            Amount = @Amount,
            [Date] = @IncomeDate,
            Title = @Title 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
        -- 4. UPDATE THE TRANSACTION TABLE
        -- Note: We use TransactionID = @IncomeId
        UPDATE [Ledger].Transactions
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            GoalID = @GoalId,
            FixedIncomeID = @FixedIncomeId,
            DebtID = @DebtId,
            Title = @Title,
            Amount = @Amount,
            AmountInSp = @AmountInSp, 
            TransactionDate = @IncomeDate,
            TransactionType = @TransactionType,
            [Description] = @Description
        WHERE TransactionID = @IncomeId AND UserID = @UserId;

        -- 5. UPDATE WALLET BALANCE (THE MATH)
        -- Scenario A: Wallet stayed the same
        IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @Amount -- Revert old, add new
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            -- Scenario B: Wallet changed (Move money between wallets)
            ELSE
            BEGIN
                -- Remove old amount from the old wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance - @OldAmount 
                WHERE WalletID = @OldWalletId AND UserID = @UserId;

                -- Add new amount to the new wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance + @Amount 
                WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 

        -- Return 1 to indicate success
        SELECT 1 AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AcceptSharedDebt]
CREATE PROCEDURE [Planning].[sp_AcceptSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL,
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @S NVARCHAR(50);
	DECLARE @Am DECIMAL(18,2);

	SELECT @S = Status, @Am = Amount 
	FROM Planning.SharedDebts WHERE DebtID = @DebtID;

	IF (@S IS NULL OR @S IN ('Accepted', 'Refused'))
	BEGIN
		;THROW 51001, 'Validation Error: Debt cannot be accepted because it does not exist or has already been processed.', 1;
	END

	BEGIN TRY
		BEGIN TRAN;
		
		UPDATE Planning.SharedDebts
		SET CreditorID = @CreditorID, DebtorID = @DebtorID, Status = 'Accepted',
			DueDate = @DueDate, CreditorWalletID = @CreditorWalletID, DebtorWalletID = @DebtorWalletID
		WHERE DebtID = @DebtID;

		INSERT INTO [Ledger].[Transactions]	([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
		VALUES (@CreditorID, @CreditorWalletID, @DebtID, @Title, @Am, 1, @Description, @AmountInSp);
		
		UPDATE Banking.Wallets SET Balance = Balance - @Am WHERE WalletID = @CreditorWalletID;

		INSERT INTO [Ledger].[Transactions]	([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
		VALUES (@DebtorID, @DebtorWalletID, @DebtID, @Title, @Am, 0, @Description, @AmountInSp);
		
		UPDATE Banking.Wallets SET Balance = Balance + @Am WHERE WalletID = @DebtorWalletID;

		COMMIT TRAN;
		SELECT 1;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_AcceptSharedDebt: ' + ERROR_MESSAGE();
		THROW 50001, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AddAmountToSavingGoalWithTransaction]
create PROCEDURE [Planning].[sp_AddAmountToSavingGoalWithTransaction]
    @GoalId INT,
    @WalletId INT,
    @UserId INT,
    @AmountFromWallet DECIMAL(18, 2),
    @AmountToSavingGoal DECIMAL(18, 2),
    @AmountInSp DECIMAL(18, 2),
    @TransactionTitle NVARCHAR(255),
    @TransactionType INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. التحقق من رصيد المحفظة باستخدام الاسكيما الصحيحة [Banking]
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId AND Balance >= @AmountFromWallet)
        BEGIN
            ;THROW 50001, 'Insufficient funds or wallet not found.', 1;
        END

        -- 2. التحقق من وجود الهدف الادخاري
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        BEGIN
            ;THROW 50002, 'Saving goal not found.', 1;
        END

        -- 3. الخصم من المحفظة الفردية داخل [Banking]
        UPDATE [Banking].[Wallets]
        SET Balance = Balance - @AmountFromWallet
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 4. الإضافة إلى رصيد الهدف الحالي
        UPDATE [Planning].[SavingsGoals]
        SET CurrentAmount = CurrentAmount + @AmountToSavingGoal
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- 5. تسجيل المعاملة المالية الموحدة بجدول الـ Transactions
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, GoalID, Title, Amount, TransactionDate, TransactionType, AmountInSp,
            CategoryID, TagID, FixedExpenseID, DebtID, FixedIncomeID, Description
        )
        VALUES (
            @UserId, @WalletId, @GoalId, @TransactionTitle, @AmountFromWallet, GETDATE(), @TransactionType, @AmountInSp,
            NULL, NULL, NULL, NULL, NULL, NULL
        );

        -- تأكيد نجاح حفظ جميع الخطوات معاً
        COMMIT TRANSACTION;
        SELECT 1 AS Success;

    END TRY
    BEGIN CATCH
        -- التراجع الشامل لحماية البيانات في حال حدوث أي خطأ مفاجئ
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AddCategoryBudget]
-- ==========================================
-- 1. Add Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_AddCategoryBudget]
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
IF EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE UserID = @UserID AND CategoryID = @CategoryID AND IsActive = 1)
    THROW 50004, 'A budget for this category already exists for the user.', 1;
   
   IF (SELECT ISNULL(SUM(PercentageLimit), 0) + @PercentageLimit FROM [Planning].[Budgets] WHERE UserID = @UserID) > 100
    THROW 50005, 'Wrong input, total categories budget percentage cannot exceed 100%.', 1;

    INSERT INTO [Planning].[Budgets] (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
    VALUES (@UserID, @CategoryID, @PercentageLimit, @StartDate, @EndDate, @IsActive);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- Schema: [Planning] | Procedure: [sp_AddSavingGoal]
CREATE PROCEDURE [Planning].[sp_AddSavingGoal]
    @UserId INT,
    @Title NVARCHAR(200),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2) = 0, 
    @DeadlineDate DATE = NULL,
    @CurrencyId INT,
    @IsAchieved BIT = 0,
    @NewGoalID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [Planning].[SavingsGoals] (
            UserID, Title, TargetAmount, CurrentAmount, DeadlineDate, IsAchieved, CurrencyID
        )
        VALUES (
            @UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate, @IsAchieved, @CurrencyId
        );

        SET @NewGoalID = SCOPE_IDENTITY();

        SELECT @NewGoalID AS NewGoalID;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AddSharedDebt]
CREATE PROCEDURE [Planning].[sp_AddSharedDebt]
	@CreditorID INT,
	@DebtorID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(200),
	@CreatedAt DATETIME,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		INSERT INTO [Planning].[SharedDebts]
			([CreditorID], [DebtorID], [Amount], [Title], [Status], [CreatedAt], [DueDate], [CreditorWalletID], [DebtorWalletID])
		VALUES
			(@CreditorID, @DebtorID, @Amount, @Title, 'Pending', @CreatedAt, @DueDate, @CreditorWalletID, @DebtorWalletID);
		
		SELECT SCOPE_IDENTITY() AS NewDebtID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_AddSharedDebt: ' + ERROR_MESSAGE();
		THROW 50002, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_CheckFixedExpenseActive]
CREATE PROCEDURE [Planning].[sp_CheckFixedExpenseActive]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IsActive 
    FROM [Planning].[FixedExpenses] 
    WHERE FixedExpenseID = @ExpenseId AND UserID = @UserId;
END
GO

-- Schema: [Planning] | Procedure: [sp_CheckFixedIncomeActive]
CREATE PROCEDURE [Planning].[sp_CheckFixedIncomeActive]
    @FixedIncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL((
        SELECT CAST(IsActive AS BIT) 
        FROM [Planning].[FixedIncomes] 
        WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId
    ), 0); 
END
GO

-- Schema: [Planning] | Procedure: [sp_CheckSavingGoalExists]
-- ==========================================
-- 8. Check Saving Goal Exists
-- ==========================================
CREATE PROCEDURE [Planning].[sp_CheckSavingGoalExists]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId)
        SELECT 1;
    ELSE
        SELECT 0;
END
GO

-- Schema: [Planning] | Procedure: [sp_CheckSharedDebtExists]
CREATE PROCEDURE [Planning].[sp_CheckSharedDebtExists]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID)
			SELECT 1 AS DebtExists;
		ELSE
			SELECT 0 AS DebtExists;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_CheckSharedDebtExists: ' + ERROR_MESSAGE();
		THROW 50003, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_CreateFixedExpense]
CREATE PROCEDURE [Planning].[sp_CreateFixedExpense]
    @OwnerId INT,
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @DueDate DATE,
    @IsActive BIT,
    @CategoryId INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @OwnerId AND Title = @Title)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user.', 1;
        END

        BEGIN TRAN;

        INSERT INTO [Planning].[FixedExpenses] 
            (UserID, CategoryID, Title, Amount, DueDate, IsActive)
        VALUES 
            (@OwnerId, @CategoryId, @Title, @Amount, @DueDate, @IsActive);
        
        DECLARE @NewID INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRAN;

        SELECT @NewID AS NewID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_CreateFixedIncome]
CREATE PROCEDURE [Planning].[sp_CreateFixedIncome]
    @UserId INT,
    @WalletId INT, 
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @IsMonthly BIT,
    @IsActive BIT,
    @Days INT = NULL,
    @LastTime DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
       
        IF @Amount <= 0
        BEGIN
            ;THROW 50010, 'The income amount must be greater than zero.', 1;
        END

            IF EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] WHERE UserID = @UserId AND WalletID = @WalletId AND Title = @Title)
        BEGIN
            ;THROW 50011, 'A fixed income with this title already exists for this wallet.', 1;
        END

        BEGIN TRAN;

           INSERT INTO [Planning].[FixedIncomes] 
           (UserID, WalletID, Title, Amount, IsMonthly, IsActive, Days, LastTime)
           VALUES 
           (@UserId, @WalletId, @Title, @Amount, @IsMonthly, @IsActive, @Days, ISNULL(@LastTime, GETDATE()));
           
           DECLARE @NewFixedIncomeID INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRAN;

        SELECT @NewFixedIncomeID AS NewFixedIncomeID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteCategoryBudget]

-- ==========================================
-- 5. Delete Single Budget 
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_DeleteCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    DELETE FROM [Planning].Budgets 
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteFixedExpense]
CREATE PROCEDURE [Planning].[sp_DeleteFixedExpense]
    @Id INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

        SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedExpenses] 
        WHERE FixedExpenseID = @Id;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50022, 'The specified fixed expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50023, 'Access denied. You do not own this fixed expense record.', 1;
        END

        BEGIN TRAN;

        DELETE FROM [Planning].[FixedExpenses]
        WHERE FixedExpenseID = @Id AND UserID = @UserId;

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteFixedIncome]
CREATE PROCEDURE [Planning].[sp_DeleteFixedIncome]
    @FixedIncomeId INT,
    @UserId INT 
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

           SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedIncomes] 
        WHERE FixedIncomeId = @FixedIncomeId;

         IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50012, 'The specified fixed income record was not found.', 1;
        END
        
          IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50013, 'Access denied. You do not own this fixed income record.', 1;
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN;

          DELETE FROM [Planning].[FixedIncomes]
        WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId;

         DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

          SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
           IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteSharedDebtById]
CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtById]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		DELETE FROM [Planning].[SharedDebts]
		WHERE [DebtID] = @DebtID AND [Status] <> 'Accepted';

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_DeleteSharedDebtById: ' + ERROR_MESSAGE();
		THROW 50005, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteSharedDebtByTitle]
CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		DELETE FROM [Planning].[SharedDebts]
		WHERE [Title] = @Title AND [Status] <> 'Accepted';

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_DeleteSharedDebtByTitle: ' + ERROR_MESSAGE();
		THROW 50004, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAchievedGoals]
-- ==========================================
-- 7. Get Achieved Saving Goals
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetAchievedGoals]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID,
        IsAchieved
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId 
      AND CurrentAmount <= TargetAmount
    ORDER BY DeadlineDate DESC;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAllUserBudgets]
-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetAllUserBudgets]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Aggregate all relevant transactions once
    ;WITH UserTotals AS (
        SELECT 
            CategoryID,
            SUM(CASE WHEN TransactionType = 0 THEN AmountInSp ELSE 0 END) AS TotalIncome,
            SUM(CASE WHEN TransactionType = 1 THEN AmountInSp ELSE 0 END) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID
        GROUP BY CategoryID
    ),
    -- 2. Get global income separately (since income isn't usually tied to a category)
    GlobalIncome AS (
        SELECT SUM(AmountInSp) as OverallIncome 
        FROM [Ledger].[Transactions] 
        WHERE UserID = @UserID AND TransactionType = 0
    )
    
    SELECT
        b.BudgetID,
        b.UserID,
        b.CategoryID,
        b.PercentageLimit,
        b.StartDate,
        b.EndDate,
        b.IsActive,

        -- The "Allowance" in currency (e.g., $300)
        CAST((gi.OverallIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        -- The "Actual Spent" in currency (e.g., $30)
        COALESCE(ut.TotalSpent, 0) AS SpendingProgress,
        -- The Percentage of the Budget used (e.g., 10%)
        CAST(
            CASE 
                WHEN gi.OverallIncome > 0 AND b.PercentageLimit > 0 
                THEN (COALESCE(ut.TotalSpent, 0) / (gi.OverallIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0 
            END AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS JOIN GlobalIncome gi
    LEFT JOIN UserTotals ut ON b.CategoryID = ut.CategoryID
    WHERE b.UserID = @UserID;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAllUserGoalsPaged]
create PROCEDURE [Planning].[sp_GetAllUserGoalsPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    
    SELECT COUNT(*) AS TotalCount
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId;

  
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID,
        IsAchieved 
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId
    ORDER BY GoalID DESC  
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetCategoryBudget]
CREATE PROCEDURE [Planning].[sp_GetCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.BudgetID, 
        b.UserID, 
        b.CategoryID, 
        b.PercentageLimit, 
        b.StartDate, 
        b.EndDate, 
        b.IsActive,
        CAST((Totals.TotalIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        
        Totals.TotalSpent AS SpendingProgress,
        
        CAST(
            CASE
                WHEN Totals.TotalIncome > 0 AND b.PercentageLimit > 0 
                THEN (Totals.TotalSpent / (Totals.TotalIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0.0
            END 
        AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS APPLY (
        SELECT
            -- Global income for the user within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 0 THEN AmountInSp END), 0) AS TotalIncome,
            -- Specific spending for ONLY this category within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 1 AND CategoryID = @CategoryID THEN AmountInSp END), 0) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID 
          AND TransactionDate BETWEEN b.StartDate AND b.EndDate
    ) AS Totals
    WHERE b.CategoryID = @CategoryID AND b.UserID = @UserID;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetFixedExpense]
CREATE PROCEDURE [Planning].[sp_GetFixedExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedExpenseID,
        UserID,
        CategoryID,
        Title, 
        Amount, 
        DueDate, 
        IsActive
    FROM [Planning].[FixedExpenses]
    WHERE FixedExpenseID = @ExpenseId AND UserID = @UserId;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetFixedExpensesByUserId]
CREATE PROCEDURE [Planning].[sp_GetFixedExpensesByUserId]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedExpenseID,
        UserID,
        CategoryID,
        Title, 
        Amount, 
        DueDate, 
        IsActive
    FROM [Planning].[FixedExpenses]
    WHERE UserID = @UserId
    ORDER BY FixedExpenseID DESC;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetFixedIncome]
CREATE PROCEDURE [Planning].[sp_GetFixedIncome]
    @FixedIncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedIncomeId, 
        UserID, 
        WalletId, 
        Title, 
        Amount, 
        IsMonthly, 
        IsActive, 
        Days, 
        LastTime
    FROM [Planning].[FixedIncomes]
    WHERE FixedIncomeId = @FixedIncomeId 
      AND UserID = @UserId;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetFixedIncomesByUser]

 CREATE PROCEDURE [Planning].[sp_GetFixedIncomesByUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedIncomeId, 
        UserID, 
        WalletId,
        Title, 
        Amount, 
        IsMonthly, 
        IsActive, 
        Days, 
        LastTime
    FROM [Planning].[FixedIncomes]
    WHERE UserID = @UserId
    ORDER BY FixedIncomeId DESC; 
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtById]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtById]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [DebtID] = @DebtID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtById: ' + ERROR_MESSAGE();
		THROW 50009, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtByTitle]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [Title] = @Title;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtByTitle: ' + ERROR_MESSAGE();
		THROW 50006, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtsForUser]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtsForUser]
	@UserID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts]
		WHERE [CreditorID] = @UserID OR [DebtorID] = @UserID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsForUser: ' + ERROR_MESSAGE();
		THROW 50010, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtsIHaveToPay]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtsIHaveToPay]
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [DebtorID] = @UserId AND Status = 'Accepted';
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsIHaveToPay: ' + ERROR_MESSAGE();
		THROW 50007, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtsOwedToUser]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtsOwedToUser]
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [CreditorID] = @UserId AND Status = 'Accepted';
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsOwedToUser: ' + ERROR_MESSAGE();
		THROW 50008, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_GetUpcomingDebtReminders]
CREATE PROCEDURE [Planning].[sp_GetUpcomingDebtReminders]
AS
BEGIN
    SET NOCOUNT ON;

    -- Fetch unpaid or partially paid debts due in exactly 2 days
    SELECT 
        sd.Title,
        (sd.Amount - sd.PaidAmount) AS RemainingAmount,
        u.FcmToken
    FROM [Planning].SharedDebts sd
    INNER JOIN [Identity].Users u ON sd.DebtorID = u.UserID
    WHERE sd.PaidAmount < sd.Amount
      AND u.FcmToken IS NOT NULL
      -- DATEDIFF ensures we match exactly 2 calendar days away regardless of time of day
      AND DATEDIFF(day, CAST(GETDATE() AS DATE), CAST(sd.DueDate AS DATE)) = 2;
END
GO

-- Schema: [Planning] | Procedure: [sp_RefuseSharedDebt]
CREATE PROCEDURE [Planning].[sp_RefuseSharedDebt]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @S NVARCHAR(50);
	SELECT @S = Status FROM Planning.SharedDebts WHERE DebtID = @DebtID;

	IF (@S IS NULL OR @S IN ('Accepted', 'Refused'))
	BEGIN
		;THROW 51011, 'Validation Error: Debt cannot be refused because it does not exist or has already been processed.', 1;
	END

	BEGIN TRY
		UPDATE Planning.SharedDebts
		SET Status = 'Refused'
		WHERE DebtID = @DebtID;

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_RefuseSharedDebt: ' + ERROR_MESSAGE();
		THROW 50011, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_ResetExpiredBudgets]
CREATE PROCEDURE [Planning].[sp_ResetExpiredBudgets]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Capture the expiring budgets and the users' device tokens first
        SELECT 
            b.BudgetID,
            u.FcmToken,
            b.PercentageLimit
        INTO #TempExpiredBudgets
        FROM [Planning].Budgets b
        INNER JOIN [Identity].Users u ON b.UserID = u.UserID
        WHERE b.IsActive = 1 
          AND b.EndDate <= CAST(GETDATE() AS DATE)
          AND u.FcmToken IS NOT NULL; -- Only care about users with active devices

        -- 2. Perform the date-rolling update
        UPDATE Budgets
        SET 
            StartDate = DATEADD(day, DATEDIFF(day, StartDate, EndDate), StartDate),
            EndDate = DATEADD(day, DATEDIFF(day, StartDate, EndDate), EndDate)
        WHERE IsActive = 1 
          AND EndDate <= CAST(GETDATE() AS DATE);

        -- 3. Return the data to your ASP.NET Core background worker
        SELECT PercentageLimit, FcmToken FROM #TempExpiredBudgets;

        DROP TABLE #TempExpiredBudgets;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_ReturnDebtAmount]
CREATE PROCEDURE [Planning].[sp_ReturnDebtAmount]
  @DebtID INT,
  @CreditorID INT,
  @DebtorID INT,
  @CreditorWalletID INT,
  @DebtorWalletID INT,
  @Amount DECIMAL(18,2),
  @Title NVARCHAR(255),
  @Description NVARCHAR(MAX) = NULL,
  @AmountInSp DECIMAL(18,2)
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON; 

  DECLARE @am DECIMAL(18,2);
  DECLARE @paiAmount DECIMAL(18,2);

  SELECT @am = ISNULL(Amount, 0), @paiAmount = ISNULL(PaidAmount, 0) 
  FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID;

  IF NOT EXISTS(SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID AND Status = 'Accepted')
  BEGIN
      ;THROW 51012, 'Validation Error: Debt must exist and be in ''Accepted'' status to process a return.', 1;
  END

  IF (@paiAmount + @Amount) > @am
  BEGIN
      ;THROW 51013, 'Validation Error: Return amount cannot exceed the total remaining debt amount.', 1;
  END

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [Ledger].[Transactions] ([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
    VALUES (@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
    
    UPDATE Banking.Wallets SET Balance = Balance + @Amount WHERE WalletID = @CreditorWalletID;

    INSERT INTO [Ledger].[Transactions] ([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
    VALUES (@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
    
    UPDATE Banking.Wallets SET Balance = Balance - @Amount WHERE WalletID = @DebtorWalletID;

    UPDATE [Planning].[SharedDebts] SET PaidAmount = ISNULL(PaidAmount, 0) + @Amount WHERE DebtID = @DebtID;

    COMMIT TRAN;
    SELECT 1;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_ReturnDebtAmount: ' + ERROR_MESSAGE();
    THROW 50012, @ErrMsg, 1;
  END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateCategoryBudget]
-- ==========================================
-- 2. Update Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_UpdateCategoryBudget]
    @BudgetID INT,
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE CategoryID = @CategoryID AND UserID = @UserID)
        THROW 50003, 'Access denied. You do not own this budget.', 1;

    UPDATE [Planning].[Budgets]
    SET PercentageLimit = @PercentageLimit,
        StartDate = @StartDate,
        EndDate = @EndDate,
        IsActive = @IsActive
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateFixedExpense]
CREATE PROCEDURE [Planning].[sp_UpdateFixedExpense]
    @Id INT,
    @OwnerId INT,
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @DueDate DATE,
    @IsActive BIT,
    @CategoryId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

        SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedExpenses] 
        WHERE FixedExpenseID = @Id;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50022, 'The specified fixed expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @OwnerId
        BEGIN
            ;THROW 50023, 'Access denied. You do not own this fixed expense record.', 1;
        END

        IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @OwnerId AND Title = @Title AND FixedExpenseID <> @Id)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user.', 1;
        END

        BEGIN TRAN;

        UPDATE [Planning].[FixedExpenses]
        SET Title = @Title,
            Amount = @Amount,
            DueDate = @DueDate,
            IsActive = @IsActive,
            CategoryID = ISNULL(@CategoryId, CategoryID)
        WHERE FixedExpenseID = @Id AND UserID = @OwnerId;

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateFixedIncome]
CREATE PROCEDURE [Planning].[sp_UpdateFixedIncome]
    @FixedIncomeId INT,
    @UserId INT, 
    @WalletId INT, 
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @IsMonthly BIT,
    @IsActive BIT,
    @Days INT = NULL,
    @LastTime DATETIME = NULL
AS
BEGIN
    -- استخدم SET NOCOUNT ON ولكن احرص على استخدام @@ROWCOUNT في نهاية الاستعلام
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. التحقق من وجود السجل والملكية (أمني)
        IF NOT EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] 
                       WHERE FixedIncomeId = @FixedIncomeId 
                         AND UserID = @UserId)
        BEGIN
            ;THROW 50012, 'The specified fixed income record was not found or access denied.', 1;
        END

        -- 2. التحقق من صحة القيم (Business Validation)
        IF @Amount <= 0
        BEGIN
            ;THROW 50013, 'The amount must be greater than zero.', 1;
        END

        -- التحقق من عدم تكرار العنوان لنفس المستخدم في نفس المحفظة
        IF EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] 
                   WHERE UserID = @UserId 
                     AND WalletId = @WalletId 
                     AND Title = @Title 
                     AND FixedIncomeId <> @FixedIncomeId)
        BEGIN
            ;THROW 50011, 'A fixed income with this title already exists in the selected wallet.', 1;
        END

        -- 3. تنفيذ التحديث
        UPDATE [Planning].[FixedIncomes]
        SET Title = @Title,
            Amount = @Amount,
            IsMonthly = @IsMonthly,
            IsActive = @IsActive,
            Days = @Days,
            LastTime = ISNULL(@LastTime, LastTime),
            WalletId = @WalletId 
        WHERE FixedIncomeId = @FixedIncomeId 
          AND UserID = @UserId;
        
        SELECT @@ROWCOUNT AS RowsAffected;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateSavingGoal]
CREATE PROCEDURE [Planning].[sp_UpdateSavingGoal]
    @GoalId INT,
    @UserId INT, -- للتحقق الأمني
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- 1. التحقق من وجود الهدف وملكيتها (IDOR)
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found or access denied.', 1;
        END

        -- 2. التحقق من صحة القيم المدخلة
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- التحقق من عدم تكرار عنوان الهدف لنفس المستخدم
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- 3. تنفيذ التحديث الأساسي فقط
        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        -- إرجاع عدد الصفوف المتأثرة
        SELECT @@ROWCOUNT AS RowsAffected;

    END TRY
    BEGIN CATCH
        -- إظهار الخطأ في حال حدوث مشكلة
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateSharedDebt]
CREATE PROCEDURE [Planning].[sp_UpdateSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@Amount DECIMAL(18,2) = NULL,
	@Title NVARCHAR(200) = NULL,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		UPDATE [Planning].[SharedDebts]
		SET
			[CreditorID] = CASE WHEN @CreditorID IS NOT NULL THEN @CreditorID ELSE [CreditorID] END,
			[DebtorID] = CASE WHEN @DebtorID IS NOT NULL THEN @DebtorID ELSE [DebtorID] END,
			[Amount] = CASE WHEN [CreditorID] = @CreditorID AND @Amount IS NOT NULL THEN @Amount ELSE [Amount] END,
			[Title] = CASE WHEN [CreditorID] = @CreditorID AND @Title IS NOT NULL THEN @Title ELSE [Title] END,
			[DueDate] = CASE WHEN [CreditorID] = @CreditorID AND @DueDate IS NOT NULL THEN @DueDate ELSE [DueDate] END,
			[CreditorWalletID] = CASE WHEN @CreditorWalletID IS NOT NULL THEN @CreditorWalletID ELSE [CreditorWalletID] END,
			[DebtorWalletID] = CASE WHEN @DebtorWalletID IS NOT NULL THEN @DebtorWalletID ELSE [DebtorWalletID] END
		WHERE [DebtID] = @DebtID;

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_UpdateSharedDebt: ' + ERROR_MESSAGE();
		THROW 50013, @ErrMsg, 1;
	END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_WithdrawAmountFromSavingGoalWithTransaction]
CREATE PROCEDURE [Planning].[sp_WithdrawAmountFromSavingGoalWithTransaction]
    @GoalId INT,
    @WalletId INT,
    @UserId INT,
    @AmountFromSavingGoal DECIMAL(18, 2),  -- المبلغ المخصوم من الهدف (بعملة الهدف)
    @AmountToWallet DECIMAL(18, 2),        -- المبلغ المضاف للمحفظة (بعملة المحفظة)
    @AmountInSp DECIMAL(18, 2),            -- القيمة بالسوري لتسجيل المعاملة
    @TransactionTitle NVARCHAR(255),
    @TransactionType INT                   
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. التحقق من وجود الهدف ورصيده الكافي للسحب (الاسكيما: Planning)
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId AND CurrentAmount >= @AmountFromSavingGoal)
        BEGIN
            ;THROW 50003, 'Insufficient funds in saving goal or goal not found.', 1;
        END

        -- 2. التحقق من وجود المحفظة (الاسكيما: Banking)
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        -- 3. الخصم من الهدف الادخاري
        UPDATE [Planning].[SavingsGoals]
        SET CurrentAmount = CurrentAmount - @AmountFromSavingGoal
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- 4. الإضافة إلى المحفظة
        UPDATE [Banking].[Wallets]
        SET Balance = Balance + @AmountToWallet
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 5. تسجيل المعاملة في جدول الـ Transactions (الاسكيما: Ledger)
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, GoalID, Title, Amount, TransactionDate, TransactionType, AmountInSp,
            CategoryID, TagID, FixedExpenseID, DebtID, FixedIncomeID, Description
        )
        VALUES (
            @UserId, @WalletId, @GoalId, @TransactionTitle, @AmountToWallet, GETDATE(), @TransactionType, @AmountInSp,
            NULL, NULL, NULL, NULL, NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT 1 AS Success;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

