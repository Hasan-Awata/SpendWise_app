CREATE PROCEDURE [Planning].[sp_AcceptSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
	DECLARE @S NVARCHAR(50);
	SELECT @S = Status FROM Planning.SharedDebts WHERE DebtID = @DebtID

	IF (@S != 'Accepted' OR @S != 'Refused')
	BEGIN
		BEGIN TRAN
			UPDATE Planning.SharedDebts
			SET CreditorID = @CreditorID,
				DebtorID = @DebtorID,
				Status = 'Accepted',
				DueDate = @DueDate,
				CreditorWalletID = @CreditorWalletID,
				DebtorWalletID = @DebtorWalletID
			WHERE DebtID = @DebtID;

			DECLARE @Am DECIMAL(18,2);
			SELECT @Am = Amount FROM Planning.SharedDebts WHERE DebtID = @DebtID;

			INSERT INTO [Ledger].[Transactions]
				([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
			VALUES
				(@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
			UPDATE Banking.Wallets
			SET Balance = Balance - @Am
			WHERE WalletID = @CreditorWalletID;

			INSERT INTO [Ledger].[Transactions]
				([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
			VALUES
				(@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
			UPDATE Banking.Wallets
			SET Balance = Balance + @Am
			WHERE WalletID = @DebtorID;

			
		COMMIT TRAN;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END
	SELECT @@ROWCOUNT AS rowsAffected;
RETURN 0