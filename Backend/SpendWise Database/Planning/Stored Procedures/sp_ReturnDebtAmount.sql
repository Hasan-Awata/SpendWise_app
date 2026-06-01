CREATE PROCEDURE [Planning].[sp_ReturnDebtAmount]
	@DebtID INT,
	@CreditorID INT,
	@DebtorID INT,
	@CreditorWalletID INT,
	@DebtorWalletID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
BEGIN
	DECLARE @am DECIMAL(18,2), @paiAmount DECIMAL(18,2);
	SET @am = (SELECT Amount FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID);
	SET @paiAmount = (SELECT PaidAmount FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID);

	IF (EXISTS (SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID AND Status = 'Accepted')
	AND (@paiAmount + @Amount) <= @am)
	BEGIN	
		BEGIN TRAN
		INSERT INTO [Ledger].[Transactions]			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES			(@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance + @Amount
		WHERE @CreditorWalletID = WalletID;

		INSERT INTO [Ledger].[Transactions]			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES			(@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance - @Amount
		WHERE @DebtorWalletID = WalletID;

		UPDATE [Planning].[SharedDebts]
		SET PaidAmount = PaidAmount + @Amount
		WHERE DebtID = @DebtID;
		COMMIT TRAN;

		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	END

	SELECT @@ROWCOUNT AS rowsAffected;
END
GO