CREATE PROCEDURE [Planning].[sp_CheckFixedIncomeActive]
    @FixedIncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- الاستعلام يرجع القيمة مباشرة ليتوافق مع الـ ExecuteScalarAsync في الـ C#
    SELECT IsActive 
    FROM [Planning].[FixedIncomes] 
    WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId;
END