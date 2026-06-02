CREATE PROCEDURE [Planning].[sp_AddSharedDebt]
	@CreditorID INT,
	@DebtorID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(200),
	@CreatedAt DATETIME,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	BEGIN TRY
		INSERT INTO [Planning].[SharedDebts]
			([CreditorID], [DebtorID], [Amount], [Title], [Status], [CreatedAt], [DueDate], [CreditorWalletID], [DebtorWalletID])
		VALUES
			(@CreditorID, @DebtorID, @Amount, @Title, 'Pending', @CreatedAt, @DueDate, @CreditorWalletID, @DebtorWalletID);
		
		SELECT SCOPE_IDENTITY() AS NewDebtID;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_AddSharedDebt: ' + ERROR_MESSAGE();
		THROW 50002, @ErrMsg, 1;
	END CATCH
END
GO