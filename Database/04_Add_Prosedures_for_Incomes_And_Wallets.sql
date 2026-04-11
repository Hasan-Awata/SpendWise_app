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
-- 3. Add a New Wallet
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance)
    VALUES (@UserId, @CurrencyId, @Balance);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ==========================================
-- 4. Update an Existing Wallet
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_UpdateWallet]
    @WalletId INT,
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE [Banking].Wallets
    SET CurrencyID = @CurrencyId,
        Balance = @Balance
    WHERE WalletID = @WalletId AND UserID = @UserId;
    
    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 5. Delete a Wallet
-- ==========================================
CREATE OR ALTER PROCEDURE [Banking].[sp_DeleteWallet]
    @WalletId INT
AS
BEGIN
    SET NOCOUNT ON;
    
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
        iw.WalletID AS IncomeWalletID, iw.Balance AS IncomeWalletBalance,
        it.TagID AS IncomeTagID, it.Name AS IncomeTagName,
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tw.WalletID AS TransWalletID, tw.Balance AS TransWalletBalance,
        tc.CategoryID, tc.Name AS CategoryName, tc.Priority AS CategoryPriority,
        tt.TagID AS TransTagID, tt.Name AS TransTagName

    FROM [Ledger].Incomes i
    INNER JOIN [Banking].Wallets iw ON i.WalletID = iw.WalletID
    LEFT JOIN [Config].Tags it ON i.TagID = it.TagID
    
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = i.IncomeID
    LEFT JOIN [Banking].Wallets tw ON tr.WalletID = tw.WalletID
    LEFT JOIN [Config].Categories tc ON tr.CategoryID = tc.CategoryID
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
        i.IncomeID, i.UserID, i.Amount, i.Date,
        w.WalletID, w.Balance,
        t.TagID, t.Name AS TagName
    FROM [Ledger].Incomes i
    INNER JOIN [Banking].Wallets w ON i.WalletID = w.WalletID
    LEFT JOIN [Config].Tags t ON i.TagID = t.TagID
    WHERE i.UserID = @UserId
    ORDER BY i.Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ==========================================
-- 3. Add Income and Transaction (Atomic)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_AddIncomeWithTransaction]
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(255) = NULL,
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
        BEGIN TRAN; -- Start Data Consistency Lock
        
        DECLARE @NewIncomeID INT;

        INSERT INTO [Ledger].Incomes (UserID, WalletID, TagID, Amount, Date)
        VALUES (@IncomeUserId, @IncomeWalletId, @IncomeTagId, @IncomeAmount, @IncomeDate);
        
        SET @NewIncomeID = SCOPE_IDENTITY();

        INSERT INTO [Ledger].Transactions 
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, IncomeID, Title, Amount, TransactionDate, TransactionType, Description)
        VALUES 
        (@IncomeUserId, @IncomeWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewIncomeID, @TransTitle, @IncomeAmount, @IncomeDate, @TransType, @TransDescription);

        COMMIT TRAN; -- Lock Released: Both Succeeded
        SELECT @NewIncomeID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert: Data stays consistent
        THROW; 
    END CATCH
END
GO

-- ==========================================
-- 4. Update Income and Transaction (Atomic)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT,
    @IncomeUserId INT,
    @IncomeWalletId INT,
    @IncomeTagId INT = NULL,
    @IncomeAmount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(255) = NULL,
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
        BEGIN TRAN; -- Start Data Consistency Lock
        
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
        END

        COMMIT TRAN; -- Lock Released: Both Updated
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 5. Delete Income and Transaction (Atomic)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        DELETE FROM [Ledger].Transactions WHERE IncomeID = @IncomeId;
        DELETE FROM [Ledger].Incomes WHERE IncomeID = @IncomeId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; -- Lock Released: Both Deleted
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO