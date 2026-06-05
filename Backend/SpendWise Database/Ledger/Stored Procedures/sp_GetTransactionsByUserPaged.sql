-- ==========================================
-- Get Transactions By User Paged 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetTransactionsByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT,
    @TagId INT = NULL,
    @CategoryId INT = NULL,
    @TransactionType INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Transactions
    WHERE UserID = @UserId
      AND (@TagId IS NULL OR TagID = @TagId)
      AND (@CategoryId IS NULL OR CategoryID = @CategoryId)
      AND (@TransactionType IS NULL OR TransactionType = @TransactionType);

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
      AND (@TagId IS NULL OR TagID = @TagId)
      AND (@CategoryId IS NULL OR CategoryID = @CategoryId)
      AND (@TransactionType IS NULL OR TransactionType = @TransactionType)
    ORDER BY [TransactionDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
