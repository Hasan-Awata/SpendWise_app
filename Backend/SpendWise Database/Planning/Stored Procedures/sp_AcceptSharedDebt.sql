CREATE PROCEDURE [Planning].[sp_AcceptSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL,
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @S NVARCHAR(50);
	DECLARE @Am DECIMAL(18,2);

	SELECT @S = Status, @Am = Amount 
	FROM Planning.SharedDebts WHERE DebtID = @DebtID;

	IF (@S IS NULL OR @S IN ('Accepted', 'Refused'))
	BEGIN
		;THROW 51001, 'Validation Error: Debt cannot be accepted because it does not exist or has already been processed.', 1;
	END

	BEGIN TRY
		BEGIN TRAN;
		
		UPDATE Planning.SharedDebts
		SET CreditorID = @CreditorID, DebtorID = @DebtorID, Status = 'Accepted',
			DueDate = @DueDate, CreditorWalletID = @CreditorWalletID, DebtorWalletID = @DebtorWalletID
		WHERE DebtID = @DebtID;

		INSERT INTO [Ledger].[Transactions]	([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
		VALUES (@CreditorID, @CreditorWalletID, @DebtID, @Title, @Am, 1, @Description, @AmountInSp);
		
		UPDATE Banking.Wallets SET Balance = Balance - @Am WHERE WalletID = @CreditorWalletID;

		INSERT INTO [Ledger].[Transactions]	([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
		VALUES (@DebtorID, @DebtorWalletID, @DebtID, @Title, @Am, 0, @Description, @AmountInSp);
		
		UPDATE Banking.Wallets SET Balance = Balance + @Am WHERE WalletID = @DebtorWalletID;

		COMMIT TRAN;
		SELECT 1;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_AcceptSharedDebt: ' + ERROR_MESSAGE();
		THROW 50001, @ErrMsg, 1;
	END CATCH
END
GO