CREATE PROCEDURE [Planning].[sp_AcceptSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@Status NVARCHAR(50),
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
	DECLARE @S NVARCHAR(50);
	SELECT @S = Status FROM Planning.SharedDebts WHERE DebtID = @DebtID

	IF (@S != 'Accepted' OR @S != 'Refused')
	BEGIN
		BEGIN TRAN
			UPDATE Planning.SharedDebts
			SET CreditorID = @CreditorID,
				DebtorID = @DebtorID,
				Status = @Status,
				DueDate = @DueDate,
				CreditorWalletID = @CreditorWalletID,
				DebtorWalletID = @DebtorWalletID
			WHERE DebtID = @DebtID;

			DECLARE @Am DECIMAL(18,2);
			SELECT @Am = Amount FROM Planning.SharedDebts WHERE DebtID = @DebtID;

			UPDATE Banking.Wallets
			SET Balance = Balance - @Am
			WHERE WalletID = @CreditorWalletID;

			UPDATE Banking.Wallets
			SET Balance = Balance - @Am
			WHERE WalletID = @DebtorID;
		COMMIT TRAN;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END
	SELECT @@ROWCOUNT AS rowsAffected;
RETURN 0