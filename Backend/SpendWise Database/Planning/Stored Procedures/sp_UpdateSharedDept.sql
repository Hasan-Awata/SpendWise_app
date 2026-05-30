CREATE PROCEDURE [Planning].[sp_UpdateSharedDebt]
	@DebtID INT,
	@UserID INT,
	@Amount DECIMAL(18,2) = NULL,
	@Title NVARCHAR(200) = NULL,
	@DueDate DATETIME = NULL,
	@Status NVARCHAR(50) = NULL
AS
BEGIN
	-- Only creditor can update amount, title, duedate
	UPDATE [Planning].[SharedDebts]
	SET
		[Amount] = CASE WHEN [CreditorID] = @UserID AND @Amount IS NOT NULL THEN @Amount ELSE [Amount] END,
		[Title] = CASE WHEN [CreditorID] = @UserID AND @Title IS NOT NULL THEN @Title ELSE [Title] END,
		[DueDate] = CASE WHEN [CreditorID] = @UserID AND @DueDate IS NOT NULL THEN @DueDate ELSE [DueDate] END,
		[Status] = CASE WHEN @Status IS NOT NULL THEN @Status ELSE [Status] END
	WHERE [DebtID] = @DebtID;
END
GO