-- ==========================================
-- 2. Get Incomes By User Paged (With Description)
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT,
    @TagId INT = NULL,
    @TransactionType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes i
    INNER JOIN [Ledger].Transactions t ON i.IncomeID = t.TransactionID
    WHERE i.UserID = @UserId
      AND (@TagId IS NULL OR i.TagID = @TagId)
      AND (@TransactionType IS NULL OR t.TransactionType = @TransactionType);

    -- Result Set 2: Paged Incomes with Transaction Details
    SELECT 
        i.IncomeID, 
        i.UserID, 
        i.Title, 
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].Incomes i
    INNER JOIN [Ledger].Transactions t ON i.IncomeID = t.TransactionID
    WHERE i.UserID = @UserId
      AND (@TagId IS NULL OR i.TagID = @TagId)
      AND (@TransactionType IS NULL OR t.TransactionType = @TransactionType)
    ORDER BY i.[Date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END