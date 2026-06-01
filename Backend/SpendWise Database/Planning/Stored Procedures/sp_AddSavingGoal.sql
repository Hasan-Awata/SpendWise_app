CREATE PROCEDURE [Planning].[sp_AddSavingGoalWithTransaction]
    @UserId INT,
    @Title NVARCHAR(200),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2) = 0, 
    @DeadlineDate DATE = NULL,
    @CurrencyId INT,
    @IsAchieved BIT = 0,
    @WalletId INT = NULL, 
    @CategoryId INT = NULL,
    @TagId INT = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @AmountInSp DECIMAL(18,2) = 0,
    @TransactionType INT = 1, 
    @NewGoalID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. التحقق من المحفظة (إن وجدت)
        IF @WalletId IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId)
            BEGIN
                ;THROW 50001, 'Wallet not found.', 1;
            END

            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
            BEGIN
                ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
            END
        END

        BEGIN TRAN;

        -- 2. إدخال الهدف الادخاري
        INSERT INTO [Planning].[SavingsGoals] (
            UserID, Title, TargetAmount, CurrentAmount, DeadlineDate, IsAchieved, CurrencyID
        )
        VALUES (
            @UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate, @IsAchieved, @CurrencyId
        );

        SET @NewGoalID = SCOPE_IDENTITY();

        IF @CurrentAmount >= 0
        BEGIN
            INSERT INTO [Ledger].[Transactions] (
                UserID, WalletID, CategoryID, TagID, GoalID, 
                Title, Amount, TransactionDate, TransactionType, 
                [Description], AmountInSp
            )
            VALUES (
                @UserId, @WalletId, @CategoryId, @TagId, @NewGoalID,
                @Title, @CurrentAmount, GETDATE(), @TransactionType,
                @Description, @AmountInSp
            );

              IF @WalletId IS NOT NULL
            BEGIN
                UPDATE [Banking].[Wallets]
                SET Balance = Balance - @CurrentAmount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        COMMIT TRAN;

        SELECT @NewGoalID AS NewGoalID;

    END TRY
    BEGIN CATCH
        -- ترتيب الـ Rollback والـ Throw بشكل يمنع أي خطأ في الـ Syntax
        IF @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRAN;
        END

        ;THROW;
    END CATCH
END
GO