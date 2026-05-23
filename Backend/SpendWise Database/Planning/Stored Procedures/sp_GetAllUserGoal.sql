-- ==========================================
-- 6. Get All User Saving Goals (Paged)
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetAllUserGoalsPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    -- First Result Set: Total Count of goals for this user
    SELECT COUNT(*) AS TotalCount
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId;

    -- Second Result Set: The actual paged goals data
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId
    ORDER BY GoalID DESC  -- Displays the newest goals first
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END