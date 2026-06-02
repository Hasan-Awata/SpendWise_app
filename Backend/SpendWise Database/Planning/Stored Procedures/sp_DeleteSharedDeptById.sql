CREATE PROCEDURE [Planning].[sp_DeleteSharedDebtById]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		DELETE FROM [Planning].[SharedDebts]
		WHERE [DebtID] = @DebtID AND [Status] <> 'Accepted';

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_DeleteSharedDebtById: ' + ERROR_MESSAGE();
		THROW 50005, @ErrMsg, 1;
	END CATCH
END
GO