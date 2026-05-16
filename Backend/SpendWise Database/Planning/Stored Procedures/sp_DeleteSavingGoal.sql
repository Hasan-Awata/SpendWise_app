-- ==========================================
-- 4. Delete Saving Goal
-- ==========================================
CREATE PROCEDURE [Planning].[sp_DeleteSavingGoal]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation: Check if the saving goal exists before attempting to delete
    IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId)
        THROW 50009, 'The specified saving goal was not found.', 1;

    -- Execute the delete operation
    DELETE FROM [Planning].[SavingsGoals]
    WHERE GoalID = @GoalId;
    
    -- Return the number of affected rows to satisfy ExecuteScalarAsync
    SELECT @@ROWCOUNT;
END