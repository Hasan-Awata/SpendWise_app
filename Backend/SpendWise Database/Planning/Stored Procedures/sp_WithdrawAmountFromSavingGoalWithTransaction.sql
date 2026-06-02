CREATE PROCEDURE [Planning].[sp_WithdrawAmountFromSavingGoalWithTransaction]
    @GoalId INT,
    @WalletId INT,
    @UserId INT,
    @AmountFromSavingGoal DECIMAL(18, 2),  -- المبلغ المخصوم من الهدف (بعملة الهدف)
    @AmountToWallet DECIMAL(18, 2),        -- المبلغ المضاف للمحفظة (بعملة المحفظة)
    @AmountInSp DECIMAL(18, 2),            -- القيمة بالسوري لتسجيل المعاملة
    @TransactionTitle NVARCHAR(255),
    @TransactionType INT                   
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. التحقق من وجود الهدف ورصيده الكافي للسحب (الاسكيما: Planning)
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId AND CurrentAmount >= @AmountFromSavingGoal)
        BEGIN
            ;THROW 50003, 'Insufficient funds in saving goal or goal not found.', 1;
        END

        -- 2. التحقق من وجود المحفظة (الاسكيما: Banking)
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        -- 3. الخصم من الهدف الادخاري
        UPDATE [Planning].[SavingsGoals]
        SET CurrentAmount = CurrentAmount - @AmountFromSavingGoal
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- 4. الإضافة إلى المحفظة
        UPDATE [Banking].[Wallets]
        SET Balance = Balance + @AmountToWallet
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 5. تسجيل المعاملة في جدول الـ Transactions (الاسكيما: Ledger)
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, GoalID, Title, Amount, TransactionDate, TransactionType, AmountInSp,
            CategoryID, TagID, FixedExpenseID, DebtID, FixedIncomeID, Description
        )
        VALUES (
            @UserId, @WalletId, @GoalId, @TransactionTitle, @AmountToWallet, GETDATE(), @TransactionType, @AmountInSp,
            NULL, NULL, NULL, NULL, NULL, NULL
        );

        COMMIT TRANSACTION;
        SELECT 1 AS Success;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO