CREATE PROCEDURE [Planning].[sp_GetSharedDebtById]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [DebtID] = @DebtID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtById: ' + ERROR_MESSAGE();
		THROW 50009, @ErrMsg, 1;
	END CATCH
END
GO