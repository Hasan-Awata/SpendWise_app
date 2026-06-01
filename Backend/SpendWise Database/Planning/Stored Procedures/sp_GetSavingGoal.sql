create PROCEDURE [Planning].[sp_GetSavingGoalById]
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
        CurrencyID,
        IsAchieved 
    FROM [Planning].[SavingsGoals]
    WHERE GoalID = @GoalId;
END