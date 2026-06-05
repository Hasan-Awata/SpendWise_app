create PROCEDURE [Planning].[sp_GetAllUserGoalsPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    
    SELECT COUNT(*) AS TotalCount
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId;

  
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
    ORDER BY GoalID DESC  
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END