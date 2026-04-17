USE SpendWiseDB;
GO

-- ==========================================
-- 1. Get Wallet By ID (Includes Currency Data)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_GetWalletById]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        w.WalletID, w.Balance, w.UserID,
        c.CurrencyID, c.CurrencyName, c.ActualValue
    FROM [Banking].Wallets w
    INNER JOIN [Config].Currencies c ON w.CurrencyID = c.CurrencyID
    WHERE w.WalletID = @WalletId AND w.UserID = @UserId;
END
GO

-- ==========================================
-- 2. Get All Wallets for a User (Includes Currency Data)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_GetUserWallets]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        w.WalletID, w.Balance, w.UserID,
        c.CurrencyID, c.CurrencyName, c.ActualValue
    FROM [Banking].Wallets w
    INNER JOIN [Config].Currencies c ON w.CurrencyID = c.CurrencyID
    WHERE w.UserID = @UserId;
END
GO

-- ==========================================
-- Add Wallet (With Currency Check/Create)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyName NVARCHAR(50),
    @ActualValue DECIMAL(18,4), -- Required for the Currencies table constraint
    @Balance DECIMAL(18,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        DECLARE @CurrencyId INT;

        -- 1. Check if the Currency already exists
        SELECT @CurrencyId = CurrencyID 
        FROM [Config].Currencies 
        WHERE CurrencyName = @CurrencyName;

        -- 2. If it does not exist, create it
        IF @CurrencyId IS NULL
        BEGIN
            INSERT INTO [Config].Currencies (CurrencyName, ActualValue)
            VALUES (@CurrencyName, @ActualValue);
            
            -- Grab the newly generated CurrencyID
            SET @CurrencyId = SCOPE_IDENTITY();
        END

        -- 3. Create the Wallet using the found/created CurrencyID
        INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance)
        VALUES (@UserId, @CurrencyId, @Balance);
        
        DECLARE @NewWalletID INT = SCOPE_IDENTITY();

        COMMIT TRAN; -- Lock Released: Both operations succeeded
        
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
-- Update Wallet (With Currency Check/Create)
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_UpdateWallet]
    @WalletId INT,
    @UserId INT,
    @CurrencyName NVARCHAR(50),
    @ActualValue DECIMAL(18,4),
    @Balance DECIMAL(18,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        DECLARE @CurrencyId INT;

        -- 1. Check if the Currency already exists
        SELECT @CurrencyId = CurrencyID 
        FROM [Config].Currencies 
        WHERE CurrencyName = @CurrencyName;

        -- 2. If it does not exist, create it
        IF @CurrencyId IS NULL
        BEGIN
            INSERT INTO [Config].Currencies (CurrencyName, ActualValue)
            VALUES (@CurrencyName, @ActualValue);
            
            SET @CurrencyId = SCOPE_IDENTITY();
        END

        -- 3. Update the Wallet using the found/created CurrencyID
        UPDATE [Banking].Wallets
        SET CurrencyID = @CurrencyId,
            Balance = @Balance
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
    @WalletId INT
AS
BEGIN
    DELETE FROM [Banking].Wallets
    WHERE WalletID = @WalletId;
    
    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 1. Get Income By ID 
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IncomeID, i.UserID AS IncomeUserID, i.Amount AS IncomeAmount, i.Date AS IncomeDate,
        iw.WalletID AS IncomeWalletID, iw.Balance AS IncomeWalletBalance, iw.IsSaved AS IsSavedWallet,
        it.TagID AS IncomeTagID, it.Name AS IncomeTagName,
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tw.WalletID AS TransWalletID, tw.Balance AS TransWalletBalance,
        tt.TagID AS TransTagID, tt.Name AS TransTagName

    FROM [Ledger].[Incomes] i
    INNER JOIN [Banking].Wallets iw ON i.WalletID = iw.WalletID
    LEFT JOIN [Config].Tags it ON i.TagID = it.TagID
    
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = i.IncomeID
    LEFT JOIN [Banking].Wallets tw ON tr.WalletID = tw.WalletID
    LEFT JOIN [Config].Tags tt ON tr.TagID = tt.TagID
    
    WHERE i.IncomeID = @IncomeId AND i.UserID = @UserId;
END
GO

-- ==========================================
-- 2. Get Incomes By User Paged
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
        i.IncomeID, i.UserID AS IncomeUserID, i.Amount AS IncomeAmount, i.Date AS IncomeDate,
        iw.WalletID AS IncomeWalletID, iw.Balance AS IncomeWalletBalance, iw.IsSaved AS IsSavedWallet,
        it.TagID AS IncomeTagID, it.Name AS IncomeTagName,
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tw.WalletID AS TransWalletID, tw.Balance AS TransWalletBalance,
        tt.TagID AS TransTagID, tt.Name AS TransTagName

    FROM [Ledger].[Incomes] i
    INNER JOIN [Banking].Wallets iw ON i.WalletID = iw.WalletID
    LEFT JOIN [Config].Tags it ON i.TagID = it.TagID
    
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = i.IncomeID
    LEFT JOIN [Banking].Wallets tw ON tr.WalletID = tw.WalletID
    LEFT JOIN [Config].Tags tt ON tr.TagID = tt.TagID
    
    WHERE i.UserID = @UserId
    ORDER BY i.Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ==========================================
-- 1. Add Income, Transaction, and Update Balance
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
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        -- 1. Check if Wallet Exists AT ALL
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        -- 2. Check if the Wallet belongs to THIS User
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        DECLARE @NewIncomeID INT;

        -- 1. Insert Income
        INSERT INTO [Ledger].Incomes (UserID, WalletID, TagID, Amount, Date)
        VALUES (@IncomeUserId, @IncomeWalletId, @IncomeTagId, @IncomeAmount, @IncomeDate);
        
        SET @NewIncomeID = SCOPE_IDENTITY();

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions 
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, IncomeID, Title, Amount, TransactionDate, TransactionType, Description)
        VALUES 
        (@IncomeUserId, @IncomeWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewIncomeID, @TransTitle, @IncomeAmount, @IncomeDate, @TransType, @TransDescription);

        -- 3. UPDATE WALLET BALANCE (Increase)
        -- We no longer need the @@ROWCOUNT check here because we validated it at the top
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
-- 2. Update Income, Transaction, and Adjust Balance
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
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        -- 1. Check if the target Wallet Exists AT ALL
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        -- 2. Check if the target Wallet belongs to THIS User
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        -- If security checks pass, start the transaction
        BEGIN TRAN; 

        -- 1. Capture the OLD amount and wallet before modifying
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @IncomeUserId;

        -- 3. Ensure the Income record actually exists and belongs to the user
        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;
        
        -- 2. Update Income
        UPDATE [Ledger].Incomes
        SET WalletID = @IncomeWalletId,
            TagID = @IncomeTagId,
            Amount = @IncomeAmount,
            Date = @IncomeDate
        WHERE IncomeID = @IncomeId AND UserID = @IncomeUserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Update Transaction and Re-calculate Balances
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

            -- BALANCE MATH
            IF @OldWalletId = @IncomeWalletId
            BEGIN
                -- If they kept the same wallet, just adjust the difference
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @IncomeAmount
                WHERE WalletID = @IncomeWalletId AND UserID = @IncomeUserId;
            END
            ELSE
            BEGIN
                -- If they changed the wallet entirely, remove from old, add to new
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
-- 3. Delete Income, Transaction, and Revert Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        -- 1. Capture the amount and wallet to revert
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId;

        -- 2. Delete dependencies
        DELETE FROM [Ledger].Transactions WHERE IncomeID = @IncomeId;
        DELETE FROM [Ledger].Incomes WHERE IncomeID = @IncomeId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Subtract the money from the wallet since the income was deleted
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Banking].Wallets 
            SET Balance = Balance - @AmountToRevert 
            WHERE WalletID = @WalletId;
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
