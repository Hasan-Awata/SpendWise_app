
 CREATE PROCEDURE [Planning].[sp_GetFixedIncomesByUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedIncomeId, 
        UserID, 
        WalletId,
        Title, 
        Amount, 
        IsMonthly, 
        IsActive, 
        Days, 
        LastTime
    FROM [Planning].[FixedIncomes]
    WHERE UserID = @UserId
    ORDER BY FixedIncomeId DESC; 
END