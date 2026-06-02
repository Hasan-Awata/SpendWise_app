CREATE PROCEDURE [Planning].[sp_RefuseSharedDebt]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @S NVARCHAR(50);
	SELECT @S = Status FROM Planning.SharedDebts WHERE DebtID = @DebtID;

	IF (@S IS NULL OR @S IN ('Accepted', 'Refused'))
	BEGIN
		;THROW 51011, 'Validation Error: Debt cannot be refused because it does not exist or has already been processed.', 1;
	END

	BEGIN TRY
		UPDATE Planning.SharedDebts
		SET Status = 'Refused'
		WHERE DebtID = @DebtID;

		SELECT @@ROWCOUNT AS rowsAffected;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_RefuseSharedDebt: ' + ERROR_MESSAGE();
		THROW 50011, @ErrMsg, 1;
	END CATCH
END
GO