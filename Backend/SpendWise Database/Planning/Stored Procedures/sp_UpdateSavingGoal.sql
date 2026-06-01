CREATE PROCEDURE [Planning].[sp_UpdateSavingGoal]
    @GoalId INT,
    @UserId INT, -- للتحقق الأمني
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- 1. التحقق من وجود الهدف وملكيتها (IDOR)
        IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found or access denied.', 1;
        END

        -- 2. التحقق من صحة القيم المدخلة
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- التحقق من عدم تكرار عنوان الهدف لنفس المستخدم
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- 3. تنفيذ التحديث الأساسي فقط
        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        -- إرجاع عدد الصفوف المتأثرة
        SELECT @@ROWCOUNT AS RowsAffected;

    END TRY
    BEGIN CATCH
        -- إظهار الخطأ في حال حدوث مشكلة
        THROW;
    END CATCH
END
GO