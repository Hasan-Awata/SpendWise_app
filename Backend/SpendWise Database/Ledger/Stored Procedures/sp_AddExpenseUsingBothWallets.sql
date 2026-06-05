-- ====================================================================
-- Add Expense, Transaction, and Deduct Balance across multiple wallets
-- ====================================================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseUsingBothWallets]
    -- Shared PARAMETERS
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @SavingWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

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
        BEGIN TRAN; 

        -- 1. UPDATE WALLETS FIRST (Strictly ordered by WalletID to prevent deadlocks)
        
        DECLARE @UpdatedRows INT = 0;

        IF @PrimaryWalletId < @SavingWalletId
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END

        -- If both wallets weren't updated, either they don't exist or the user doesn't own them
        IF @UpdatedRows < 2
        BEGIN
            ;THROW 50001, 'Wallet validation failed. Check ownership or existence.', 1;
        END

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@UserId, @PrimaryWalletId, @CategoryId, @TagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @Title, @Amount, @AmountInSp, @Date, @TransactionType, @Description);

        SET @NewExpenseID = SCOPE_IDENTITY();
        
        -- 3. Insert Expense
        INSERT INTO [Ledger].Expenses (ExpenseID ,UserID, Title, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@NewExpenseID, @UserId, @Title, @PrimaryWalletId, @TagId, @CategoryId, @Products, @Amount, @Date);

        -- 4. COMMIT TRANSACTION ASAP
        COMMIT TRAN; 

        -- 5. POST-TRANSACTION BUDGET CHECK
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END