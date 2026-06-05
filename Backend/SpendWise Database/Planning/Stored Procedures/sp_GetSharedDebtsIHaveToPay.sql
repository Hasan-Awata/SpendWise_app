CREATE PROCEDURE [Planning].[sp_GetSharedDebtsIHaveToPay]
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [DebtorID] = @UserId AND Status = 'Accepted';
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsIHaveToPay: ' + ERROR_MESSAGE();
		THROW 50007, @ErrMsg, 1;
	END CATCH
END
GO