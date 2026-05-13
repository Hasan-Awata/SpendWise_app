-- ==========================================
-- 3. Add Expense, Transaction, and Deduct Balance
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
   -- Expense PARAMETERS
   @ExpenseUserId INT,
    @ExpenseWalletId INT,
    @ExpenseCategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @ExpenseTagId INT = NULL,
    @ExpenseAmount DECIMAL(18,2),
    @ExpenseDate DATETIME,
    
    -- Transaction PARAMETERS
    @TransTitle NVARCHAR(255),
    @TransDescription NVARCHAR(MAX) = NULL,
    @TransType INT,
    @TransAmountInSp DECIMAL(18,2), 
    @TransCategoryId INT,
    @TransTagId INT = NULL,
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
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId)
        BEGIN
            THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId)
        BEGIN
            THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Insert Expense
        INSERT INTO [Ledger].Expenses (UserID, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@ExpenseUserId, @ExpenseWalletId, @ExpenseTagId, @ExpenseCategoryId, @Products, @ExpenseAmount, @ExpenseDate);
        
        SET @NewExpenseID = SCOPE_IDENTITY();

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, ExpenseID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@ExpenseUserId, @ExpenseWalletId, @TransCategoryId, @TransTagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @NewExpenseID, @TransTitle, @ExpenseAmount, @TransAmountInSp, @ExpenseDate, @TransType, @TransDescription);

        -- 3. UPDATE WALLET BALANCE (DEDUCT FOR EXPENSE)
        UPDATE [Banking].Wallets
        SET Balance = Balance - @ExpenseAmount
        WHERE WalletID = @ExpenseWalletId AND UserID = @ExpenseUserId;

        -- 4. CALCULATE BUDGET STATUS USING CENTRALIZED FUNCTION
        -- The function is called before COMMIT so it includes the transaction just inserted.
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@ExpenseUserId, @ExpenseCategoryId, @ExpenseDate);

        COMMIT TRAN; 

        -- Return values for the application layer
        SELECT @NewExpenseID AS NewExpenseID, @IsOverLimit AS IsOverLimit;

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END