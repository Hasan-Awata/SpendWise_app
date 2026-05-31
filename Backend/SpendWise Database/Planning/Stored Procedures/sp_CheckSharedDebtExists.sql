CREATE PROCEDURE [dbo].[sp_CheckSharedDebtExists]
	@DebtID INT
AS
	IF EXISTS (SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID)
        SELECT 1;
    ELSE
        SELECT 0;
RETURN 0
