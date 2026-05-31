CREATE PROCEDURE [Planning].[sp_GetFixedExpensesByUserId]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedExpenseID,
        UserID,
        CategoryID,
        Title, 
        Amount, 
        DueDate, 
        IsActive
    FROM [Planning].[FixedExpenses]
    WHERE UserID = @UserId
    ORDER BY FixedExpenseID DESC;
END