create PROCEDURE [Planning].[sp_AddAmountToSavingGoalWithTransaction]
    @GoalId INT,
    @WalletId INT,
    @UserId INT,
    @AmountFromWallet DECIMAL(18, 2),
    @AmountToSavingGoal DECIMAL(18, 2),
    @AmountInSp DECIMAL(18, 2),
    @TransactionTitle NVARCHAR(255),
    @TransactionType INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. التحقق من رصيد المحفظة باستخدام الاسكيما الصحيحة [Banking]
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId AND Balance >= @AmountFromWallet)
        BEGIN
            ;THROW 50001, 'Insufficient funds or wallet not found.', 1;
        END

        -- 2. التحقق من وجود الهدف الادخاري
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        BEGIN
            ;THROW 50002, 'Saving goal not found.', 1;
        END

        -- 3. الخصم من المحفظة الفردية داخل [Banking]
        UPDATE [Banking].[Wallets]
        SET Balance = Balance - @AmountFromWallet
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 4. الإضافة إلى رصيد الهدف الحالي
        UPDATE [Planning].[SavingsGoals]
        SET CurrentAmount = CurrentAmount + @AmountToSavingGoal
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- 5. تسجيل المعاملة المالية الموحدة بجدول الـ Transactions
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, GoalID, Title, Amount, TransactionDate, TransactionType, AmountInSp,
            CategoryID, TagID, FixedExpenseID, DebtID, FixedIncomeID, Description
        )
        VALUES (
            @UserId, @WalletId, @GoalId, @TransactionTitle, @AmountFromWallet, GETDATE(), @TransactionType, @AmountInSp,
            NULL, NULL, NULL, NULL, NULL, NULL
        );

        -- تأكيد نجاح حفظ جميع الخطوات معاً
        COMMIT TRANSACTION;
        SELECT 1 AS Success;

    END TRY
    BEGIN CATCH
        -- التراجع الشامل لحماية البيانات في حال حدوث أي خطأ مفاجئ
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO