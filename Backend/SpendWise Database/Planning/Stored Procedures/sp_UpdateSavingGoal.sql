-- ==========================================
-- 3. Update Saving Goal
-- ==========================================
CREATE PROCEDURE [Planning].[sp_UpdateSavingGoal]
    @GoalId INT,
    @UserId INT,
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation: Check if the saving goal exists for this user
    IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId AND UserID = @UserId)
        THROW 50008, 'The specified saving goal was not found for this user.', 1;

    -- Validation: Check if another saving goal with the same title already exists for this user
    IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        THROW 50006, 'A saving goal with this title already exists for the user.', 1;
   
    -- Validation: Target amount must be greater than zero
    IF @TargetAmount <= 0
        THROW 50007, 'The target amount must be greater than zero.', 1;

    -- Execute the update operation
    UPDATE [Planning].[SavingsGoals]
    SET Title = @Title,
        TargetAmount = @TargetAmount,
        CurrentAmount = @CurrentAmount,
        DeadlineDate = @DeadlineDate
    WHERE GoalID = @GoalId AND UserID = @UserId;
    
    -- Return the number of affected rows to satisfy ExecuteScalarAsync
    SELECT @@ROWCOUNT;
END