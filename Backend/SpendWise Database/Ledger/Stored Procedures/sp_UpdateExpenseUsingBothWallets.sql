CREATE PROCEDURE [Ledger].[sp_UpdateExpenseUsingBothWallets]
    @ExpenseId INT,
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

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
    SET @IsOverLimit = 0;

    BEGIN TRY
        -- ==========================================
        -- 1. STATE FETCH (Fetch historical state)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldPrimaryWalletId INT;
        
        SELECT 
            @ActualOwnerId = UserID, 
            @OldAmount = Amount, 
            @OldPrimaryWalletId = WalletID 
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

        -- DYNAMIC LOOKUP: Find the new saving wallet paired with the new primary wallet
        DECLARE @NewSavingWalletId INT;
        SELECT @NewSavingWalletId = W2.WalletID
        FROM [Banking].Wallets W1
        JOIN [Banking].Wallets W2 ON W1.CurrencyID = W2.CurrencyID 
            AND W2.IsSaved = 1
            AND W2.UserID = @UserId
        WHERE W1.WalletID = @PrimaryWalletId;

        -- ==========================================
        -- 2. TRANSACTION EXECUTION
        -- ==========================================
        BEGIN TRAN; 

        -- Update Expense Table
        UPDATE [Ledger].Expenses
        SET WalletID = @PrimaryWalletId, 
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date,
            Title = @Title
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            -- Update Transaction Table
            UPDATE [Ledger].Transactions
            SET WalletID = @PrimaryWalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description,
                GoalID = @GoalId,
                FixedExpenseID = @FixedExpenseId,
                FixedIncomeID = @FixedIncomeId,
                DebtID = @DebtId
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- =========================================================
            -- 3. NET BALANCE MATH (Your Reversal Logic + New Deductions)
            -- =========================================================
            DECLARE @WalletAdjustments TABLE (
                WalletID INT,
                Modifier DECIMAL(18,2)
            );

            -- Step A: Full Refund to the Old Primary Wallet
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES (@OldPrimaryWalletId, @OldAmount);

            -- Step B: Apply New Deductions to New Wallets
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES 
            (@PrimaryWalletId, -@AmountFromPrimaryWallet),
            (@NewSavingWalletId, -@AmountFromSavingWallet);

            -- Process physical database updates grouped and in strict WalletID order.
            -- This cleanly handles cases where @OldPrimaryWalletId and @PrimaryWalletId 
            -- are the exact same row by combining them into one single atomic update.
            DECLARE @CurrentWalletID INT;
            DECLARE @CurrentModifier DECIMAL(18,2);

            DECLARE WalletCursor CURSOR LOCAL FAST_FORWARD FOR
                SELECT WalletID, SUM(Modifier) 
                FROM @WalletAdjustments 
                WHERE WalletID IS NOT NULL
                GROUP BY WalletID
                HAVING SUM(Modifier) <> 0 -- Skip if the net change is perfectly zero
                ORDER BY WalletID ASC;    -- Anti-deadlock sorting

            OPEN WalletCursor;
            FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @CurrentModifier
                WHERE WalletID = @CurrentWalletID AND UserID = @UserId;

                FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;
            END

            CLOSE WalletCursor;
            DEALLOCATE WalletCursor;
        END

        COMMIT TRAN; 

        -- 4. POST-TRANSACTION BUDGET EVALUATION
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END