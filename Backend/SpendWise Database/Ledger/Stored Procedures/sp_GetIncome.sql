-- ==========================================
-- 1. Get Income By ID (Optimized: No Joins Needed!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Income and Transaction Details
    SELECT 
        i.IncomeID, i.UserID AS IncomeUserID, i.Amount AS IncomeAmount, i.Date AS IncomeDate,
        i.WalletID AS IncomeWalletID, 
        i.TagID AS IncomeTagID, 
        
        tr.TransactionID, tr.UserID AS TransUserID, tr.Title, tr.Description, 
        tr.Amount AS TransAmount, tr.TransactionDate, tr.TransactionType,
        tr.GoalID, tr.FixedExpenseID, tr.FixedIncomeID, tr.DebtID,
        tr.WalletID AS TransWalletID, 
        tr.CategoryID, 
        tr.TagID AS TransTagID
    FROM [Ledger].Incomes i
    LEFT JOIN [Ledger].Transactions tr ON tr.IncomeID = i.IncomeID
    WHERE i.IncomeID = @IncomeId AND i.UserID = @UserId;

    -- Result Set 2: Currency and Wallet Info
    SELECT 
        w.WalletID, 
        w.Balance, 
        w.CurrencyID,
        c.CurrencyName, 
        c.CurrencyCode
    FROM [Banking].Wallets w
    INNER JOIN [Config].Currencies c ON w.CurrencyID = c.CurrencyID
    WHERE w.WalletID = (SELECT WalletID FROM [Ledger].Incomes WHERE IncomeID = @IncomeId)
      AND w.UserID = @UserId;

END
