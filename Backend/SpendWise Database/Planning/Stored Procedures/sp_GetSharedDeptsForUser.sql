CREATE PROCEDURE [Planning].[sp_GetSharedDebtsForUser]
	@UserID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		SELECT * FROM [Planning].[SharedDebts]
		WHERE [CreditorID] = @UserID OR [DebtorID] = @UserID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_GetSharedDebtsForUser: ' + ERROR_MESSAGE();
		THROW 50010, @ErrMsg, 1;
	END CATCH
END
GO