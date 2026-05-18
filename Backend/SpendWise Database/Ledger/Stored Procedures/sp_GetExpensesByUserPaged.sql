
-- ==========================================
-- 2. Get Expenses By User Paged (Optimized: No Joins!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetExpensesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Expenses
    WHERE UserID = @UserId;

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
    WHERE e.UserID = @UserId
    ORDER BY Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
