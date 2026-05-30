CREATE PROCEDURE [Planning].[sp_GetSharedDebtById]
	@DebtID INT
AS
BEGIN
	SELECT * FROM [Planning].[SharedDebts] WHERE [DebtID] = @DebtID;
END
GO