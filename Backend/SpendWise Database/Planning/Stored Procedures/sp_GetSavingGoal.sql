-- ==========================================
-- 5. Get Single Saving Goal By ID
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetSavingGoalById]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID
    FROM [Planning].[SavingsGoals]
    WHERE GoalID = @GoalId;
END