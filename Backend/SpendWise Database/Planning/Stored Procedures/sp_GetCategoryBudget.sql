CREATE PROCEDURE [Planning].[sp_GetCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.BudgetID, 
        b.UserID, 
        b.CategoryID, 
        b.PercentageLimit, 
        b.StartDate, 
        b.EndDate, 
        b.IsActive,
        CAST((Totals.TotalIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        
        Totals.TotalSpent AS SpendingProgress,
        
        CAST(
            CASE
                WHEN Totals.TotalIncome > 0 AND b.PercentageLimit > 0 
                THEN (Totals.TotalSpent / (Totals.TotalIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0.0
            END 
        AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS APPLY (
        SELECT
            -- Global income for the user within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 0 THEN AmountInSp END), 0) AS TotalIncome,
            -- Specific spending for ONLY this category within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 1 AND CategoryID = @CategoryID THEN AmountInSp END), 0) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID 
          AND TransactionDate BETWEEN b.StartDate AND b.EndDate
    ) AS Totals
    WHERE b.CategoryID = @CategoryID AND b.UserID = @UserID;
END