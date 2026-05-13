CREATE PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        ExpenseID, 
        UserID, 
        Amount, 
        Products, 
        [Date], 
        WalletID, 
        CategoryID, 
        TagID
    FROM [Ledger].[Expenses]
    WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
END