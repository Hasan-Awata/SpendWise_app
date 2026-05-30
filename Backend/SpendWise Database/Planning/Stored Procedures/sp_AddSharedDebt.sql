CREATE PROCEDURE [Planning].[sp_AddSharedDebt]
	@CreditorID INT,
	@DebtorID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(200),
	@Status NVARCHAR(50),
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	INSERT INTO [Planning].[SharedDebts]
		([CreditorID], [DebtorID], [Amount], [Title], [Status], [DueDate], [CreditorWalletID], [DebtorWalletID])
	VALUES
		(@CreditorID, @DebtorID, @Amount, @Title, @Status, @DueDate, @CreditorWalletID, @DebtorWalletID);
	SELECT SCOPE_IDENTITY();
END
GO