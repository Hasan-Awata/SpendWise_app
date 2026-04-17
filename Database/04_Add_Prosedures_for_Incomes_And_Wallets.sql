USE SpendWiseDB;
GO

-- ==========================================
-- 1. Get Wallet By ID (Optimized)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_GetWalletById]
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

-- ==========================================
-- 2. Get All Wallets for a User (Optimized)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_GetUserWallets]
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

-- ==========================================
-- Add Wallet (Strict Currency Link)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT
AS
BEGIN
    SET NOCOUNT ON;
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

-- ==========================================
-- Update Wallet 
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_UpdateWallet]
    @WalletId INT,
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT 
AS
BEGIN
    SET NOCOUNT ON;
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

-- ==========================================
-- 5. Delete a Wallet
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_DeleteWallet]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
    
    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 1. Get Income By ID (Optimized: No Joins Needed!)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetIncome]
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

-- ==========================================
-- 2. Get Incomes By User Paged (Optimized: No Joins Needed!)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
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

-- ==========================================
-- 3. Add Income, Transaction, and Update Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_AddIncomeWithTransaction]
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
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
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, IncomeID, Title, Amount, TransactionDate, TransactionType, Description)
        VALUES 
        (@IncomeUserId, @IncomeWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewIncomeID, @TransTitle, @IncomeAmount, @IncomeDate, @TransType, @TransDescription);

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

-- ==========================================
-- 4. Update Income, Transaction, and Adjust Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT,
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
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

-- ==========================================
-- 5. Delete Income, Transaction, and Revert Balance (Secured)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT,
    @UserId INT -- Enforcing IDOR Security
AS
BEGIN
    SET NOCOUNT ON;
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
