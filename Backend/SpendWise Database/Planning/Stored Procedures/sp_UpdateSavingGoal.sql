-- ==========================================
-- 3. Update Saving Goal, Sync Transactions, and Adjust Wallet Balances
-- ==========================================
CREATE PROCEDURE [Planning].[sp_UpdateSavingGoal]
    -- Saving Goal Parameters
    @GoalId INT,
    @UserId INT, -- Kept for strict IDOR Security verification
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE,

    -- Transaction & Wallet Sync Parameters
    @WalletId INT,
    @CategoryId INT,
    @AmountInSp DECIMAL(18,2),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS (IDOR)
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Target wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- SAVING GOAL SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldCurrentAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        -- Retrieve the existing state of the saving goal
        SELECT 
            @ActualOwnerId = UserID, 
            @OldCurrentAmount = CurrentAmount
        FROM [Planning].[SavingsGoals] 
        WHERE GoalID = @GoalId;

        -- 1. Verify existence
        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found.', 1;
        END
        
        -- 2. Verify authorization
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this saving goal.', 1;
        END

        -- Fetch the old wallet ID historically linked to this savings progress transaction
        SELECT TOP 1 @OldWalletId = WalletID
        FROM [Ledger].[Transactions]
        WHERE GoalID = @GoalId AND UserID = @UserId
        ORDER BY TransactionDate DESC;

        -- Fallback if an initial transaction was never logged for this goal
        IF @OldWalletId IS NULL SET @OldWalletId = @WalletId;

        -- ==========================================
        -- CORE BUSINESS VALUE VALIDATIONS
        -- ==========================================
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- Prevent duplicate titles across different goals for the same user
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN; 

        -- Step 1. Update core Saving Goal values
        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- Step 2. Sync underlying Ledger logs and swap wallet balances if goal exists
        IF @RowsAffected > 0
        BEGIN
            -- If a ledger entry exists, update it. If not, generate an entry for the fresh deposit funds.
            IF EXISTS (SELECT 1 FROM [Ledger].[Transactions] WHERE GoalID = @GoalId AND UserID = @UserId)
            BEGIN
                UPDATE [Ledger].[Transactions]
                SET WalletID = @WalletId,
                    CategoryID = @CategoryId,
                    Title = @Title,
                    Amount = @CurrentAmount,
                    AmountInSp = @AmountInSp, 
                    TransactionDate = GETDATE(),
                    TransactionType = @TransactionType,
                    Description = @Description
                WHERE GoalID = @GoalId AND UserID = @UserId;
            END
            ELSE IF @CurrentAmount > 0
            BEGIN
                INSERT INTO [Ledger].[Transactions]
                    (UserID, WalletID, CategoryID, GoalID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
                VALUES
                    (@UserId, @WalletId, @CategoryId, @GoalId, @Title, @CurrentAmount, @AmountInSp, GETDATE(), @TransactionType, @Description);
            END

            -- Step 3. Balance Reversion Math Logic (Deducting/refunding capital differences)
            IF @OldWalletId = @WalletId
            BEGIN
                -- Money allocated to savings acts like an expense. 
                -- If new savings amount is larger, deduct more from wallet. If lower, refund back to wallet.
                UPDATE [Banking].[Wallets]
                SET Balance = Balance + @OldCurrentAmount - @CurrentAmount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            ELSE
            BEGIN
                -- Wallet has swapped. Refund old wallet completely, then charge the new wallet.
                UPDATE [Banking].[Wallets] 
                SET Balance = Balance + @OldCurrentAmount 
                WHERE WalletID = @OldWalletId AND UserID = @UserId;

                UPDATE [Banking].[Wallets] 
                SET Balance = Balance - @CurrentAmount 
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        COMMIT TRAN; 

        -- Return execution details to satisfy ExecuteScalarAsync / Reader context
        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END