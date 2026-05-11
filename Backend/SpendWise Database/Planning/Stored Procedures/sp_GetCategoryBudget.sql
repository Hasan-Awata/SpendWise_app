
-- ==========================================
-- 4. Get Single Budget (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.BudgetID, b.UserID, b.CategoryID, b.PercentageLimit, b.StartDate, b.EndDate, b.IsActive,
        CAST(
            CASE
                WHEN Totals.TotalIncome > 0 AND b.PercentageLimit > 0 THEN
                    (Totals.TotalSpent / (Totals.TotalIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0.0
            END 
        AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS APPLY (
        SELECT
            COALESCE((SELECT SUM(AmountInSp) FROM [Ledger].[Transactions] WHERE UserID = b.UserID AND TransactionType = 0 AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalIncome,
            COALESCE((SELECT SUM(AmountInSp) FROM [Ledger].[Transactions] WHERE UserID = b.UserID AND CategoryID = b.CategoryID AND TransactionType = 1 AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalSpent
    ) AS Totals
    WHERE b.CategoryID = @CategoryID AND b.UserID = @UserID; -- Changed WHERE clause
END
