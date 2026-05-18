-- ==========================================
-- 4. Delete Saving Goal, Remove Transactions, and Refund Wallet Balance
-- ==========================================
CREATE PROCEDURE [Planning].[sp_DeleteSavingGoal]
    @GoalId INT,
    @UserId INT -- Added for strict IDOR Security verification
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ==========================================
        -- STRICT SECURITY & AUDIT CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @AmountToRefund DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        -- Retrieve goal details and locate the last linked wallet from transactions to issue a refund
        SELECT 
            @ActualOwnerId = UserID, 
            @AmountToRefund = CurrentAmount
        FROM [Planning].[SavingsGoals] 
        WHERE GoalID = @GoalId;

        -- 1. Verify existence of the goal record
        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found.', 1;
        END

        -- 2. Verify ownership context
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this saving goal.', 1;
        END

        -- Fetch the target wallet used for this saving goal from the transactions ledger
        SELECT TOP 1 @WalletId = WalletID 
        FROM [Ledger].[Transactions]
        WHERE GoalID = @GoalId AND UserID = @UserId
        ORDER BY TransactionDate DESC;

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN; 

        -- 1. Clean up audit dependency trail from Ledger records safely
        DELETE FROM [Ledger].[Transactions] 
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- 2. Delete the core saving goal record
        DELETE FROM [Planning].[SavingsGoals] 
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Refund saved capital back to the wallet if the goal held funds
        IF @RowsAffected > 0 AND @AmountToRefund > 0 AND @WalletId IS NOT NULL
        BEGIN
            UPDATE [Banking].[Wallets] 
            SET Balance = Balance + @AmountToRefund 
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 

        -- Return the number of affected rows to satisfy ExecuteScalarAsync in C#
        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        -- Rollback if any structural rule or runtime error threatens data isolation
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END