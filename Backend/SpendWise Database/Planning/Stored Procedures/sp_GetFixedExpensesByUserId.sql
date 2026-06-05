CREATE PROCEDURE [Planning].[sp_GetFixedExpensesByUserId]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FixedExpenseID, UserId, WalletId, Title, Amount, IsMonthly, IsActive, Days, LastTime
    FROM [Planning].[FixedExpenses]
    WHERE UserID = @UserId;
END
GO