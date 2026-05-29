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