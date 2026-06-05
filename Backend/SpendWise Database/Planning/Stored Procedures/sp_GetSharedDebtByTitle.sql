CREATE PROCEDURE [Planning].[sp_GetSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [Title] = @Title;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtByTitle: ' + ERROR_MESSAGE();
		THROW 50006, @ErrMsg, 1;
	END CATCH
END
GO