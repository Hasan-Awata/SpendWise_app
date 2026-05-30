CREATE PROCEDURE [Planning].[sp_ReturnDebtAmount]
	@DebtID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
BEGIN
	DECLARE @CreditorID INT, @CreditorWalletID INT, @DebtorID INT, @DebtorWalletID INT;
	SELECT @CreditorID = CreditorID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @DebtorID = DebtorID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @CreditorWalletID = CreditorWalletID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @DebtorWalletID = DebtorWalletID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	
	BEGIN TRAN
		INSERT INTO [Ledger].[Transactions]
			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES
			(@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance + @Amount
		WHERE @CreditorWalletID = WalletID;

		INSERT INTO [Ledger].[Transactions]
			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES
			(@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance - @Amount
		WHERE @DebtorWalletID = WalletID;
	COMMIT TRAN;

	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
END
GO