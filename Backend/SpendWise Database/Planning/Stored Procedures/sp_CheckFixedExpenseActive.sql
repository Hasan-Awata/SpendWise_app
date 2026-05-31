CREATE PROCEDURE [Planning].[sp_CheckFixedExpenseActive]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IsActive 
    FROM [Planning].[FixedExpenses] 
    WHERE FixedExpenseID = @ExpenseId AND UserID = @UserId;
END