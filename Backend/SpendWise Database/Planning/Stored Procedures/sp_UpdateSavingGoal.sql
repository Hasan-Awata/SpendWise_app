create PROCEDURE [Planning].[sp_UpdateSavingGoal]
    @GoalId INT,
    @UserId INT,
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- التحقق الأمني
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found or access denied.', 1;
        END

        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- التحديث الفعلي
        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate
        WHERE GoalID = @GoalId AND UserID = @UserId;

        -- حذفنا جملة الـ SELECT من هنا لسلامة الـ NonQuery

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END