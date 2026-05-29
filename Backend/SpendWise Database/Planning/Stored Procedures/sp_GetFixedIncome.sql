
CREATE PROCEDURE [Planning].[sp_GetFixedIncome]
    @FixedIncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        FixedIncomeId, 
        UserID, 
     
        Title, 
        Amount, 
        IsMonthly, 
        IsActive, 
        Days, 
        LastTime
    FROM [Planning].[FixedIncomes]
    WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId;
END