-- ==========================================
-- 1. Get Expense By ID (Optimized: No Joins!)
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetExpense]
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

-- ==========================================
-- 2. Get Expenses By User Paged (Optimized: No Joins!)
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

-- ==========================================
-- 3. Add Expense, Transaction, and Deduct Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
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

-- ==========================================
-- 4. Update Expense, Transaction, and Adjust Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
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

-- ==========================================
-- 5. Delete Expense, Transaction, and Refund Balance
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_DeleteExpense]
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

-- ==========================================
-- 6. Get Products JSON String
-- ==========================================
CREATE OR ALTER PROCEDURE [Ledger].[sp_GetProducts]
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Products 
    FROM [Ledger].[Expenses] 
    WHERE ExpenseID = @ExpenseId;
END
GO