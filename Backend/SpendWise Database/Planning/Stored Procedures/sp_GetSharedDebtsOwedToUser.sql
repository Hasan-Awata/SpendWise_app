CREATE PROCEDURE [Planning].[sp_GetSharedDebtsOwedToUser]
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts] WHERE [CreditorID] = @UserId AND Status = 'Accepted';
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsOwedToUser: ' + ERROR_MESSAGE();
		THROW 50008, @ErrMsg, 1;
	END CATCH
END
GO