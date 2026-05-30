CREATE PROCEDURE [Planning].[sp_DeleteSharedDebt]
	@DebtID INT
AS
BEGIN
	DELETE FROM [Planning].[SharedDebts]
	WHERE [DebtID] = @DebtID AND [Status] <> 'Accepted';
END
GO