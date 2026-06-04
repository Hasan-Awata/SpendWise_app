CREATE PROCEDURE [Planning].[sp_CheckFixedExpenseActive]
    @FixedExpenseID INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IsActive 
    FROM [Planning].[FixedExpenses] 
    WHERE FixedExpenseID = @FixedExpenseID AND UserID = @UserId;
END
GO