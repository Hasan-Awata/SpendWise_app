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
    [Title] nvarchar(25) NOT NULL,
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
    [CreditorID] int NOT NULL,
    [DebtorID] int NOT NULL,
    [Amount] decimal NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Status] nvarchar(50) NOT NULL,
    [CreatedAt] datetime NOT NULL,
    [DueDate] datetime NULL
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
            THROW 50001, 'The specified Currency ID does not exist.', 1; 
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

-- Schema: [dbo] | Procedure: [sp_UpdateUserRefreshToken]
CREATE PROCEDURE [dbo].[sp_UpdateUserRefreshToken]
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
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

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
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

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
    ORDER BY [TransactionDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
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
    IF EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE UserID = @UserID AND CategoryID = @CategoryID)
        THROW 50004, 'A budget for this category already exists for the user.', 1;
   
   IF (SELECT ISNULL(SUM(PercentageLimit), 0) + @PercentageLimit FROM [Planning].[Budgets] WHERE UserID = @UserID) > 100
    THROW 50005, 'Wrong input, total categories budget percentage cannot exceed 100%.', 1;

    INSERT INTO [Planning].[Budgets] (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
    VALUES (@UserID, @CategoryID, @PercentageLimit, @StartDate, @EndDate, @IsActive);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
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

-- Schema: [Planning] | Procedure: [sp_GetCategoryBudget]

-- ==========================================
-- 4. Get Single Budget (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.BudgetID, b.UserID, b.CategoryID, b.PercentageLimit, b.StartDate, b.EndDate, b.IsActive,
        CAST(
            CASE
                WHEN Totals.TotalIncome > 0 AND b.PercentageLimit > 0 THEN
                    (Totals.TotalSpent / (Totals.TotalIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0.0
            END 
        AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS APPLY (
        SELECT
            COALESCE((SELECT SUM(AmountInSp) FROM [Ledger].[Transactions] WHERE UserID = b.UserID AND TransactionType = 0 AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalIncome,
            COALESCE((SELECT SUM(AmountInSp) FROM [Ledger].[Transactions] WHERE UserID = b.UserID AND CategoryID = b.CategoryID AND TransactionType = 1 AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalSpent
    ) AS Totals
    WHERE b.CategoryID = @CategoryID AND b.UserID = @UserID; 
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

