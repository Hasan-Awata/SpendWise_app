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
    [Password] nvarchar(255) NOT NULL
);
GO

CREATE TABLE [Ledger].[Expenses] (
    [ExpenseID] int NOT NULL,
    [UserID] int NOT NULL,
    [TagID] int NULL,
    [CategoryID] int NOT NULL,
    [WalletID] int NOT NULL,
    [Products] nvarchar(1000) NOT NULL,
    [Amount] decimal NOT NULL,
    [Date] datetime NOT NULL
);
GO

CREATE TABLE [Ledger].[Incomes] (
    [IncomeID] int NOT NULL,
    [UserID] int NOT NULL,
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
    [ExpenseID] int NULL,
    [IncomeID] int NULL,
    [Title] nvarchar(255) NOT NULL,
    [Amount] decimal NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [TransactionType] int NOT NULL,
    [Description] nvarchar(255) NULL,
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
    [IsAchieved] bit NOT NULL
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

-- Schema: [Identity] | Procedure: [sp_AddUser]

-- ==========================================
-- 1. Add User (Optimized and Secured)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_AddUser]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Explicit duplicate username check
        IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        BEGIN
            -- This maps to your DuplicateResourceException in C#
            THROW 2627, 'This username is already taken.', 1; 
        END

        INSERT INTO [Identity].Users (FirstName, LastName, Username, Password)
        VALUES (@FirstName, @LastName, @Username, @Password);
        
        -- Return the newly generated UserID directly
        SELECT CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
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
    
    SELECT UserID, FirstName, LastName, Username, Password
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
    
    SELECT UserID, FirstName, LastName, Username, Password
    FROM [Identity].Users
    WHERE Username = @Username;
END

GO

-- Schema: [Ledger] | Procedure: [sp_AddExpenseWithTransaction]

-- ==========================================
-- 3. Add Expense, Transaction, and Deduct Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
    @ExpenseUserId INT,
    @ExpenseWalletId INT,
    @ExpenseCategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @ExpenseTagId INT = NULL,
    @ExpenseAmount DECIMAL(18,2),
    @ExpenseDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransAmountInSp DECIMAL(18,2), 
    @TransCategoryId INT,
    @TransTagId INT = NULL,
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        DECLARE @NewExpenseID INT;

        -- 1. Insert Expense (Now including Products)
        INSERT INTO [Ledger].Expenses (UserID, WalletID, TagID, CategoryID, Products, Amount, Date)
        VALUES (@ExpenseUserId, @ExpenseWalletId, @ExpenseTagId, @ExpenseCategoryId, @Products, @ExpenseAmount, @ExpenseDate);
        
        SET @NewExpenseID = SCOPE_IDENTITY();

        -- 2. Insert Transaction (Linking to ExpenseID instead of IncomeID)
        INSERT INTO [Ledger].Transactions 
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, ExpenseID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES 
        (@ExpenseUserId, @ExpenseWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewExpenseID, @TransTitle, @ExpenseAmount, @TransAmountInSp, @ExpenseDate, @TransType, @TransDescription);

        -- 3. UPDATE WALLET BALANCE (DEDUCT FOR EXPENSE)
        UPDATE [Banking].Wallets
        SET Balance = Balance - @ExpenseAmount
        WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;

        COMMIT TRAN; 
        SELECT @NewExpenseID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END

GO

-- Schema: [Ledger] | Procedure: [sp_AddIncomeWithTransaction]

-- ==========================================
-- 3. Add Income, Transaction, and Update Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_AddIncomeWithTransaction]
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransAmountInSp DECIMAL(18,2), 
    @TransCategoryId INT = NULL,
    @TransTagId INT = NULL,
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        DECLARE @NewIncomeID INT;

        INSERT INTO [Ledger].Incomes (UserID, WalletID, TagID, Amount, Date)
        VALUES (@IncomeUserId, @IncomeWalletId, @IncomeTagId, @IncomeAmount, @IncomeDate);
        
        SET @NewIncomeID = SCOPE_IDENTITY();

        INSERT INTO [Ledger].Transactions 
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, IncomeID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES 
        (@IncomeUserId, @IncomeWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewIncomeID, @TransTitle, @IncomeAmount, @TransAmountInSp, @IncomeDate, @TransType, @TransDescription);
        
        UPDATE [Banking].Wallets
        SET Balance = Balance + @IncomeAmount
        WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId;

        COMMIT TRAN; 
        SELECT @NewIncomeID;
    END TRY
    BEGIN CATCH
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
            THROW 50002, 'Expense record was not found.', 1;
        END

        IF @ActualOwnerId <> @UserId
        BEGIN
            THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Delete dependencies safely
        DELETE FROM [Ledger].Transactions WHERE ExpenseID = @ExpenseId;
        DELETE FROM [Ledger].Expenses WHERE ExpenseID = @ExpenseId;
        
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
-- 5. Delete Income, Transaction, and Revert Balance (Secured)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT,
    @UserId INT -- Enforcing IDOR Security
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
        DELETE FROM [Ledger].Transactions WHERE IncomeID = @IncomeId AND UserID = @UserId;
        DELETE FROM [Ledger].Incomes WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
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
-- ==========================================
-- 1. Get Expense By ID (Optimized: No Joins!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ExpenseID, 
        UserID, 
        Amount, 
        Products, 
        Date, 
        WalletID, 
        CategoryID, 
        TagID
    FROM [Ledger].[Expenses]
    WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
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
        ExpenseID, 
        UserID, 
        Amount, 
        Products, 
        Date, 
        WalletID, 
        CategoryID, 
        TagID
    FROM [Ledger].[Expenses]
    WHERE UserID = @UserId
    ORDER BY Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END

GO

-- Schema: [Ledger] | Procedure: [sp_GetIncome]

-- ==========================================
-- 1. Get Income By ID (Optimized: No Joins Needed!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IncomeID, i.UserID AS IncomeUserID, i.Amount AS IncomeAmount, i.Date AS IncomeDate,
        i.WalletID AS IncomeWalletID, 
        i.TagID AS IncomeTagID, 
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tr.WalletID AS TransWalletID, 
        tr.CategoryID, 
        tr.TagID AS TransTagID

    FROM [Ledger].Incomes i
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = i.IncomeID
    WHERE i.IncomeID = @IncomeId AND i.UserID = @UserId;
END

GO

-- Schema: [Ledger] | Procedure: [sp_GetIncomesByUserPaged]

-- ==========================================
-- 2. Get Incomes By User Paged (Optimized: No Joins Needed!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

    SELECT 
        IncomeID, UserID, Amount, Date, WalletID, TagID
    FROM [Ledger].Incomes
    WHERE UserID = @UserId
    ORDER BY Date DESC
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

-- Schema: [Ledger] | Procedure: [sp_UpdateExpenseWithTransaction]

-- ==========================================
-- 4. Update Expense, Transaction, and Adjust Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
    @ExpenseId INT,
    @ExpenseUserId INT,
    @ExpenseWalletId INT,
    @ExpenseCategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @ExpenseTagId INT = NULL,
    @ExpenseAmount DECIMAL(18,2),
    @ExpenseDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransAmountInSp DECIMAL(18,2),
    @TransCategoryId INT = NULL,
    @TransTagId INT = NULL,
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- STRICT EXPENSE SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @ActualOwnerId = UserID, @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @ExpenseUserId
        BEGIN
            THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 

        -- 1. Update Expense
        UPDATE [Ledger].Expenses
        SET WalletID = @ExpenseWalletId,
            CategoryID = @ExpenseCategoryId,
            TagID = @ExpenseTagId,
            Products = @Products,
            Amount = @ExpenseAmount,
            Date = @ExpenseDate
        WHERE ExpenseID = @ExpenseId AND UserID = @ExpenseUserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            -- 2. Update Transaction
            UPDATE [Ledger].Transactions
            SET WalletID = @ExpenseWalletId,
                CategoryID = @TransCategoryId,
                TagID = @TransTagId,
                GoalID = @GoalId,
                FixedExpenseID = @FixedExpenseId,
                FixedIncomeID = @FixedIncomeId,
                DebtID = @DebtId,
                Title = @TransTitle,
                Amount = @ExpenseAmount,
                AmountInSp = @TransAmountInSp, 
                TransactionDate = @ExpenseDate,
                TransactionType = @TransType,
                Description = @TransDescription
            WHERE ExpenseID = @ExpenseId AND UserID = @ExpenseUserId;

            -- 3. BALANCE MATH (Revert old deduction, apply new deduction)
            IF @OldWalletId = @ExpenseWalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @OldAmount - @ExpenseAmount
                WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;
            END
            ELSE
            BEGIN
                UPDATE [Banking].Wallets SET Balance = Balance + @OldAmount WHERE WalletID = @OldWalletId AND UserID = @ExpenseUserId;
                UPDATE [Banking].Wallets SET Balance = Balance - @ExpenseAmount WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;
            END
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

-- Schema: [Ledger] | Procedure: [sp_UpdateIncomeWithTransaction]
-- ==========================================
-- 4. Update Income, Transaction, and Adjust Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT,
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransAmountInSp DECIMAL(18,2), 
    @TransCategoryId INT = NULL,
    @TransTagId INT = NULL,
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 

        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @IncomeUserId;

        -- 3. Ensure the Income record actually exists and belongs to the user
        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;
        
        UPDATE [Ledger].Incomes
        SET WalletID = @IncomeWalletId,
            TagID = @IncomeTagId,
            Amount = @IncomeAmount,
            Date = @IncomeDate
        WHERE IncomeID = @IncomeId AND UserID = @IncomeUserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            UPDATE [Ledger].Transactions
            SET WalletID = @IncomeWalletId,
                CategoryID = @TransCategoryId,
                TagID = @TransTagId,
                GoalID = @GoalId,
                FixedExpenseID = @FixedExpenseId,
                FixedIncomeID = @FixedIncomeId,
                DebtID = @DebtId,
                Title = @TransTitle,
                Amount = @IncomeAmount,
                AmountInSp = @TransAmountInSp, 
                TransactionDate = @IncomeDate,
                TransactionType = @TransType,
                Description = @TransDescription
            WHERE IncomeID = @IncomeId AND UserID = @IncomeUserId;

            IF @OldWalletId = @IncomeWalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @IncomeAmount
                WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId;
            END
            ELSE
            BEGIN
                UPDATE [Banking].Wallets SET Balance = Balance - @OldAmount WHERE WalletID = @OldWalletId AND UserID = @IncomeUserId;
                UPDATE [Banking].Wallets SET Balance = Balance + @IncomeAmount WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId;
            END
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

-- Schema: [Planning] | Procedure: [sp_GetAllUserBudgets]

-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetAllUserBudgets]
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
        -- Calculate Percentage Progress securely to avoid Divide By Zero
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
            -- Get Total Income (Type 0) in SYP during this budget period
            COALESCE((SELECT SUM(AmountInSp)
                      FROM [Ledger].[Transactions]
                      WHERE UserID = b.UserID AND TransactionType = 0
                      AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalIncome,

            -- Get Total Spent (Type 1) in SYP for this specific category during the budget period
            COALESCE((SELECT SUM(AmountInSp)
                      FROM [Ledger].[Transactions]
                      WHERE UserID = b.UserID AND CategoryID = b.CategoryID AND TransactionType = 1
                      AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalSpent
    ) AS Totals
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
    IF NOT EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE BudgetID = @BudgetID AND UserID = @UserID)
        THROW 50003, 'Access denied. You do not own this budget.', 1;

    UPDATE [Planning].[Budgets]
    SET CategoryID = @CategoryID,
        PercentageLimit = @PercentageLimit,
        StartDate = @StartDate,
        EndDate = @EndDate,
        IsActive = @IsActive
    WHERE BudgetID = @BudgetID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END

GO

