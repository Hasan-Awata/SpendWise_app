CREATE PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID, 
        e.UserID,
        e.Title,
        e.Amount, 
        e.Products, 
        e.[Date], 
        e.WalletID, 
        e.CategoryID, 
        e.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Expenses] e
    INNER JOIN [Ledger].[Transactions] t ON e.ExpenseID = t.TransactionID
    WHERE ExpenseID = @ExpenseId AND e.UserID = @UserId;
END
