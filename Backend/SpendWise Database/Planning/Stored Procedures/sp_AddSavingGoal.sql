-- ==========================================
-- Add Saving Goal, Create Tracking Transaction, and Deduct Wallet Balance
-- ==========================================
CREATE PROCEDURE [Planning].[sp_AddSavingGoalWithTransaction]
    -- Saving Goal Parameters
    @UserId INT,
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE,

    -- Transaction & Wallet Parameters
    @WalletId INT,
    @CategoryId INT, -- e.g., A system category ID assigned for Savings/Investments
    @AmountInSp DECIMAL(18,2),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, -- Defaulting to Expense type layout

    -- Output Parameter
    @NewGoalID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY & VALIDATION CHECKS
        -- ==========================================
        
        -- 1. Core Target Validations
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- 2. Prevent duplicate goal titles for the same user
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- 3. Only run Wallet validations if money is actually being allocated right now
        IF @CurrentAmount > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId)
            BEGIN
                ;THROW 50001, 'Wallet not found.', 1;
            END

            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
            BEGIN
                ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
            END
            
            -- Optional: Check if wallet has sufficient balance before proceeding
            IF (SELECT Balance FROM [Banking].[Wallets] WHERE WalletID = @WalletId) < @CurrentAmount
            BEGIN
                ;THROW 50009, 'Insufficient wallet balance for this initial savings allocation.', 1;
            END
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN;

        -- Step 1: Insert into SavingsGoals to get the primary key ID
        INSERT INTO [Planning].[SavingsGoals] 
            (UserID, Title, TargetAmount, CurrentAmount, DeadlineDate)
        VALUES 
            (@UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate);
        
        SET @NewGoalID = CAST(SCOPE_IDENTITY() AS INT);

        -- Step 2: If there is an initial amount allocated, run ledger tracking changes
        IF @CurrentAmount > 0
        BEGIN
            -- Insert Audit Transaction record referencing the newly created GoalID
            INSERT INTO [Ledger].[Transactions] 
                (UserID, WalletID, CategoryID, GoalID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
            VALUES 
                (@UserId, @WalletId, @CategoryId, @NewGoalID, @Title, @CurrentAmount, @AmountInSp, GETDATE(), @TransactionType, @Description);

            -- Deduct the initial savings allocation from the originating wallet balance
            UPDATE [Banking].[Wallets]
            SET Balance = Balance - @CurrentAmount
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN;

        -- Return values for the application layer execution satisfaction
        SELECT @NewGoalID AS NewGoalID;

    END TRY
    BEGIN CATCH
        -- Rollback if any unexpected exception or constraint error breaks execution context
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END