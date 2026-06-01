CREATE PROCEDURE [Planning].[sp_AddSharedDebt]
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(200),
	@CreatedAt DATETIME,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	INSERT INTO [Planning].[SharedDebts]
		([CreditorID], [DebtorID], [Amount], [Title], [CreatedAt], [DueDate], [CreditorWalletID], [DebtorWalletID])
	VALUES
		(@CreditorID, @DebtorID, @Amount, @Title, @CreatedAt, @DueDate, @CreditorWalletID, @DebtorWalletID);
	SELECT SCOPE_IDENTITY();
END
GO