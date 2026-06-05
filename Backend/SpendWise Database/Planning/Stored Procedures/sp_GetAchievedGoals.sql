-- ==========================================
-- 7. Get Achieved Saving Goals
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetAchievedGoals]
    @UserId INT
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
        CurrencyID,
        IsAchieved
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId 
      AND CurrentAmount <= TargetAmount
    ORDER BY DeadlineDate DESC;
END