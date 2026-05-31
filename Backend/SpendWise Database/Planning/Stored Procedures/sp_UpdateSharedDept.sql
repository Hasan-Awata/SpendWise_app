CREATE PROCEDURE [Planning].[sp_UpdateSharedDebt]
	@DebtID INT,
	@CreditorID INT = NULL,
	@DebtorID INT = NULL,
	@Amount DECIMAL(18,2) = NULL,
	@Title NVARCHAR(200) = NULL,
	@DueDate DATETIME = NULL,
	@Status NVARCHAR(50) = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	-- Only creditor can update amount, title, duedate
	UPDATE [Planning].[SharedDebts]
	SET
		[CreditorID] = CASE WHEN @CreditorID IS NOT NULL THEN @CreditorID ELSE [CreditorID] END,
		[DebtorID] = CASE WHEN @DebtorID IS NOT NULL THEN @DebtorID ELSE [DebtorID] END,
		[Amount] = CASE WHEN [CreditorID] = @CreditorID AND @Amount IS NOT NULL THEN @Amount ELSE [Amount] END,
		[Title] = CASE WHEN [CreditorID] = @CreditorID AND @Title IS NOT NULL THEN @Title ELSE [Title] END,
		[DueDate] = CASE WHEN [CreditorID] = @CreditorID AND @DueDate IS NOT NULL THEN @DueDate ELSE [DueDate] END,
		[Status] = CASE WHEN @Status IS NOT NULL THEN @Status ELSE [Status] END,
		[CreditorWalletID] = CASE WHEN @CreditorWalletID IS NOT NULL THEN @CreditorWalletID ELSE [CreditorWalletID] END,
		[DebtorWalletID] = CASE WHEN @DebtorWalletID IS NOT NULL THEN @DebtorWalletID ELSE [DebtorWalletID] END
	WHERE [DebtID] = @DebtID;

	SELECT @@ROWCOUNT AS rowsAffected;
END
GO