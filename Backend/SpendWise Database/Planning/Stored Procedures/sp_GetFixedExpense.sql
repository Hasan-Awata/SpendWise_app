CREATE PROCEDURE [Planning].[sp_GetFixedExpense]
    @ExpenseId INT,
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
    WHERE FixedExpenseID = @ExpenseId AND UserID = @UserId;
END