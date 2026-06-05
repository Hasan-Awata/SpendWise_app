CREATE PROCEDURE [Planning].[sp_CheckFixedIncomeActive]
    @FixedIncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ISNULL((
        SELECT CAST(IsActive AS BIT) 
        FROM [Planning].[FixedIncomes] 
        WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId
    ), 0); 
END