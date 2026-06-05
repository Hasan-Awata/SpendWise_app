CREATE PROCEDURE [Planning].[sp_CheckSharedDebtExists]
	@DebtID INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID)
			SELECT 1 AS DebtExists;
		ELSE
			SELECT 0 AS DebtExists;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_CheckSharedDebtExists: ' + ERROR_MESSAGE();
		THROW 50003, @ErrMsg, 1;
	END CATCH
END
GO