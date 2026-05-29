
CREATE PROCEDURE [Planning].[sp_GetFixedIncomesByUser]
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
    WHERE UserID = @UserId
    ORDER BY FixedIncomeId DESC; -- يعرض الأحدث أولاً
END