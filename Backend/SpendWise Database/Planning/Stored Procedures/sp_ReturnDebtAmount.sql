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
  SET NOCOUNT ON;
  SET XACT_ABORT ON; 

  DECLARE @am DECIMAL(18,2);
  DECLARE @paiAmount DECIMAL(18,2);

  SELECT @am = ISNULL(Amount, 0), @paiAmount = ISNULL(PaidAmount, 0) 
  FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID;

  IF NOT EXISTS(SELECT 1 FROM [Planning].[SharedDebts] WHERE DebtID = @DebtID AND Status = 'Accepted')
  BEGIN
      ;THROW 51012, 'Validation Error: Debt must exist and be in ''Accepted'' status to process a return.', 1;
  END

  IF (@paiAmount + @Amount) > @am
  BEGIN
      ;THROW 51013, 'Validation Error: Return amount cannot exceed the total remaining debt amount.', 1;
  END

  BEGIN TRY
    BEGIN TRAN;

    INSERT INTO [Ledger].[Transactions] ([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
    VALUES (@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
    
    UPDATE Banking.Wallets SET Balance = Balance + @Amount WHERE WalletID = @CreditorWalletID;

    INSERT INTO [Ledger].[Transactions] ([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description], [AmountInSp])
    VALUES (@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
    
    UPDATE Banking.Wallets SET Balance = Balance - @Amount WHERE WalletID = @DebtorWalletID;

    UPDATE [Planning].[SharedDebts] SET PaidAmount = ISNULL(PaidAmount, 0) + @Amount WHERE DebtID = @DebtID;

    COMMIT TRAN;
    SELECT 1;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(2048) = 'Database Error in sp_ReturnDebtAmount: ' + ERROR_MESSAGE();
    THROW 50012, @ErrMsg, 1;
  END CATCH
END
GO