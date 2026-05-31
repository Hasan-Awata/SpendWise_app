CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtById]
	@DebtID INT
AS
BEGIN
	DELETE FROM [Planning].[SharedDebts]
	WHERE [DebtID] = @DebtID AND [Status] <> 'Accepted';

	SELECT @@ROWCOUNT AS rowsAffected;
END
GO