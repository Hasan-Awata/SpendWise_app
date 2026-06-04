-- ==========================================
-- 1. Get Income By ID 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IncomeID, 
        i.UserID,
        i.Title,
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp],
        w.CurrencyID
    FROM [Ledger].[Incomes] i
    INNER JOIN [Ledger].[Transactions] t ON i.IncomeID = t.TransactionID
    INNER JOIN [Banking].Wallets w on i.WalletID = w.WalletID
    WHERE i.IncomeID = @IncomeID AND i.UserID = @UserID;
END