USE SpendWiseDB;
GO

-- ==========================================
-- 1. Get Expense By ID 
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID, e.UserID AS ExpenseUserID, e.Amount AS ExpenseAmount, e.Date AS ExpenseDate,
        iw.WalletID AS ExpenseWalletID, iw.Balance AS ExpenseWalletBalance, iw.IsSaved AS IsSavedWallet,
        it.TagID AS ExpenseTagID, it.Name AS ExpenseTagName,
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tw.WalletID AS TransWalletID, tw.Balance AS TransWalletBalance,
		tc.CategoryID, tc.Name AS CategoryName, tc.Priority AS CategoryPriority,
        tt.TagID AS TransTagID, tt.Name AS TransTagName

    FROM [Ledger].[Expenses] e
    INNER JOIN [Banking].Wallets iw ON e.WalletID = iw.WalletID
    LEFT JOIN [Config].Tags it ON e.TagID = it.TagID
    
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = e.ExpenseID
    LEFT JOIN [Banking].Wallets tw ON tr.WalletID = tw.WalletID
	LEFT JOIN [Config].Categories tc ON tr.CategoryID = tc.CategoryID
    LEFT JOIN [Config].Tags tt ON tr.TagID = tt.TagID
    
    WHERE e.ExpenseID = @ExpenseId AND e.UserID = @UserId;
END
GO

-- ==========================================
-- 2. Get Expenses By User Paged
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetExpensesByUserPaged]
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
        e.ExpenseID, e.UserID AS ExpenseUserID, e.Amount AS ExpenseAmount, e.Date AS ExpenseDate,
        iw.WalletID AS ExpenseWalletID, iw.Balance AS ExpenseWalletBalance, iw.IsSaved AS IsSavedWallet,
        it.TagID AS ExpenseTagID, it.Name AS ExpenseTagName,
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        
        tw.WalletID AS TransWalletID, tw.Balance AS TransWalletBalance,
		tc.CategoryID, tc.Name AS CategoryName, tc.Priority AS CategoryPriority,
        tt.TagID AS TransTagID, tt.Name AS TransTagName

    FROM [Ledger].[Expenses] e
    INNER JOIN [Banking].Wallets iw ON e.WalletID = iw.WalletID
    LEFT JOIN [Config].Tags it ON e.TagID = it.TagID
    
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = e.ExpenseID
    LEFT JOIN [Banking].Wallets tw ON tr.WalletID = tw.WalletID
	LEFT JOIN [Config].Categories tc ON tr.CategoryID = tc.CategoryID
    LEFT JOIN [Config].Tags tt ON tr.TagID = tt.TagID
    
    WHERE e.UserID = @UserId
    ORDER BY e.Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ==========================================
-- 1. Add Expense, Transaction, and Update Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
    @ExpenseUserId INT,
    @ExpenseWalletId INT,
    @ExpenseTagId INT = NULL,
	@ExpenseCategoryId INT,
    @ExpenseAmount DECIMAL(18,2),
    @ExpenseDate DATETIME,
    
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransCategoryId INT,
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
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        -- 2. Check if the Wallet belongs to THIS User
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        DECLARE @NewExpenseID INT;

        -- 1. Insert Expense
        INSERT INTO [Ledger].Expenses (UserID, WalletID, TagID, Amount, Date, CategoryID)
        VALUES (@ExpenseUserId, @ExpenseWalletId, @ExpenseTagId, @ExpenseAmount, @ExpenseDate, @ExpenseCategoryId);
        
        SET @NewExpenseID = SCOPE_IDENTITY();

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions 
        (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, IncomeID, Title, Amount, TransactionDate, TransactionType, Description)
        VALUES 
        (@ExpenseUserId, @ExpenseWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewExpenseID, @TransTitle, @ExpenseAmount, @ExpenseDate, @TransType, @TransDescription);

        -- 3. UPDATE WALLET BALANCE (Increase)
        -- We no longer need the @@ROWCOUNT check here because we validated it at the top
        UPDATE [Banking].Wallets
        SET Balance = Balance + @ExpenseAmount
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
-- ==========================================
-- 2. Update Income, Transaction, and Adjust Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
    @ExpenseId INT,
    @ExpenseUserId INT,
    @ExpenseWalletId INT,
	@ExpenseCategoryId INT,
    @ExpenseTagId INT = NULL,
    @ExpenseAmount DECIMAL(18,2),
    @ExpenseDate DATETIME,
    
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
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        -- 2. Check if the target Wallet belongs to THIS User
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        -- If security checks pass, start the transaction
        BEGIN TRAN; 

        -- 1. Capture the OLD amount and wallet before modifying
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId AND UserID = @ExpenseUserId;

        -- 3. Ensure the Income record actually exists and belongs to the user
        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;
        
        -- 2. Update Income
        UPDATE [Ledger].Expenses
        SET WalletID = @ExpenseWalletId,
            TagID = @ExpenseTagId,
            Amount = @ExpenseAmount,
            Date = @ExpenseDate
        WHERE ExpenseID = @ExpenseId AND UserID = @ExpenseUserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Update Transaction and Re-calculate Balances
        IF @RowsAffected > 0
        BEGIN
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
                TransactionDate = @ExpenseDate,
                TransactionType = @TransType,
                Description = @TransDescription
            WHERE IncomeID = @ExpenseId AND UserID = @ExpenseUserId;

            -- BALANCE MATH
            IF @OldWalletId = @ExpenseWalletId
            BEGIN
                -- If they kept the same wallet, just adjust the difference
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @ExpenseAmount
                WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;
            END
            ELSE
            BEGIN
                -- If they changed the wallet entirely, remove from old, add to new
                UPDATE [Banking].Wallets SET Balance = Balance - @OldAmount WHERE WalletID = @OldWalletId AND UserID = @ExpenseUserId;
                UPDATE [Banking].Wallets SET Balance = Balance + @ExpenseAmount WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;
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
CREATE OR ALTER PROCEDURE [Ledger].[sp_DeleteExpense]
    @ExpenseId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        -- 1. Capture the amount and wallet to revert
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        -- 2. Delete dependencies
        DELETE FROM [Ledger].Transactions WHERE ExpenseID = @ExpenseId;
        DELETE FROM [Ledger].Expenses WHERE ExpenseID = @ExpenseId;
        
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

CREATE OR ALTER PROCEDURE [Ledger].[sp_GetProducts]
    @ExpenseId INT
AS
	SET NOCOUNT ON;

	SELECT Products FROM [Ledger].[Expenses] WHERE ExpenseID = @ExpenseId
GO