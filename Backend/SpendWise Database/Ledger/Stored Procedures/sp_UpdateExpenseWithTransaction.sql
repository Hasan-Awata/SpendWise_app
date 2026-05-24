
-- ==========================================
-- 4. Update Expense, Transaction, and Adjust Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
    @ExpenseId INT,
    @UserId INT,
    @WalletId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1,
    @AmountInSp DECIMAL(18,2),
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS (IDOR)
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- EXPENSE SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @ActualOwnerId = UserID, @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 

        -- 1. Update Expense
        UPDATE [Ledger].Expenses
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- Update Transaction and Wallets (Only if expense exists)
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Ledger].Transactions
            SET WalletID = @WalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- Balance Math logic 
            IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @OldAmount - @Amount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            ELSE
            BEGIN
                UPDATE [Banking].Wallets SET Balance = Balance + @OldAmount WHERE WalletID = @OldWalletId AND UserID = @UserId;
                UPDATE [Banking].Wallets SET Balance = Balance - @Amount WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        -- Update the output variable using the function
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        COMMIT TRAN; 

        -- Return as result set for the Reader
        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END