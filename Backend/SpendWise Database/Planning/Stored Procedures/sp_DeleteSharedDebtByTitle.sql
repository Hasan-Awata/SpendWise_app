CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	DELETE FROM [Planning].[SharedDebts]
	WHERE [Title] = @Title AND [Status] <> 'Accepted';

	SELECT @@ROWCOUNT AS rowsAffected;
END
GO