CREATE PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT, -- This is also the TransactionID
    @UserId INT,
    @WalletId INT, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 0,
    @AmountInSp DECIMAL(18,2), 
    @CategoryId INT = NULL,
    @GoalId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

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

        -- 2. FETCH OLD DATA FOR RE-BALANCING
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        -- fetch the old values
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;

        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;

        -- 3. UPDATE THE INCOME TABLE
        UPDATE [Ledger].Incomes
        SET WalletID = @WalletId,
            TagID = @TagId,
            Amount = @Amount,
            [Date] = @IncomeDate,
            Title = @Title 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
        -- 4. UPDATE THE TRANSACTION TABLE
        -- Note: We use TransactionID = @IncomeId
        UPDATE [Ledger].Transactions
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            GoalID = @GoalId,
            FixedIncomeID = @FixedIncomeId,
            DebtID = @DebtId,
            Title = @Title,
            Amount = @Amount,
            AmountInSp = @AmountInSp, 
            TransactionDate = @IncomeDate,
            TransactionType = @TransactionType,
            [Description] = @Description
        WHERE TransactionID = @IncomeId AND UserID = @UserId;

        -- 5. UPDATE WALLET BALANCE (THE MATH)
        -- Scenario A: Wallet stayed the same
        IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @Amount -- Revert old, add new
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            -- Scenario B: Wallet changed (Move money between wallets)
            ELSE
            BEGIN
                -- Remove old amount from the old wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance - @OldAmount 
                WHERE WalletID = @OldWalletId AND UserID = @UserId;

                -- Add new amount to the new wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance + @Amount 
                WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 

        -- Return 1 to indicate success
        SELECT 1 AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END