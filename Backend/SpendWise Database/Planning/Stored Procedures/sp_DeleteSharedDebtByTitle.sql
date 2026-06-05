CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		DELETE FROM [Planning].[SharedDebts]
		WHERE [Title] = @Title AND [Status] <> 'Accepted';

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_DeleteSharedDebtByTitle: ' + ERROR_MESSAGE();
		THROW 50004, @ErrMsg, 1;
	END CATCH
END
GO