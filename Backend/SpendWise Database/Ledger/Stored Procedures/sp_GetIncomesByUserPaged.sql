
-- ==========================================
-- 2. Get Incomes By User Paged 
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count 
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

    -- Result Set 2: Paged Incomes
    -- We use a CTE or a temporary variable to capture which IDs we are looking at
    -- so we can easily fetch their Wallet info in the next result set.
    SELECT 
        IncomeID, UserID, Amount, Date, WalletID, TagID
    INTO #CurrentPageIncomes
    FROM [Ledger].Incomes
    WHERE UserID = @UserId
    ORDER BY Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT * FROM #CurrentPageIncomes;

    -- Result Set 3: Unique Wallets and Currencies for this page
    -- This avoids sending "US Dollar" 50 times if all 50 incomes are from the same wallet.
    SELECT DISTINCT
        w.WalletID, 
        w.Balance, 
        w.CurrencyID,
        c.CurrencyName, 
        c.CurrencyCode
    FROM [Banking].Wallets w
    INNER JOIN [Config].Currencies c ON w.CurrencyID = c.CurrencyID
    WHERE w.WalletID IN (SELECT WalletID FROM #CurrentPageIncomes)
      AND w.UserID = @UserId;

    DROP TABLE #CurrentPageIncomes;
END
