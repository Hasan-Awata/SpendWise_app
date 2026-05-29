-- ==========================================
-- Get Transactions By User Paged 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetTransactionsByUserPaged]
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

    -- Result Set 2: Paged Transactions with Transaction Details
    SELECT 
        TransactionID,
        UserID,
        Title,
        Description,
        Amount,
        AmountInSp,
        TransactionDate,
        TransactionType,
        WalletID,
        CategoryID,
        TagID,
        GoalID,
        FixedExpenseID,
        FixedIncomeID,
        DebtID
        
    FROM [Ledger].Transactions
    WHERE UserID = @UserId
    ORDER BY [TransactionDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
