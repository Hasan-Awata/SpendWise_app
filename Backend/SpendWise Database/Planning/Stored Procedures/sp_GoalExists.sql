-- ==========================================
-- 8. Check Saving Goal Exists
-- ==========================================
CREATE PROCEDURE [Planning].[sp_CheckSavingGoalExists]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId)
        SELECT 1;
    ELSE
        SELECT 0;
END
