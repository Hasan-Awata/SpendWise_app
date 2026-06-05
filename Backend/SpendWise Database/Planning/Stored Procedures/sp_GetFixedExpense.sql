CREATE PROCEDURE [Planning].[sp_GetFixedExpense]
    @FixedExpenceId INT, 
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FixedExpenseID, UserId, WalletId, Title, Amount, IsMonthly, IsActive, Days, LastTime
    FROM [Planning].[FixedExpenses]
    WHERE FixedExpenseID = @FixedExpenceId AND UserID = @UserId;
END
GO