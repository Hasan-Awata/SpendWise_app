
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
