-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetAllUserBudgets]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Aggregate all relevant transactions once
    ;WITH UserTotals AS (
        SELECT 
            CategoryID,
            SUM(CASE WHEN TransactionType = 0 THEN AmountInSp ELSE 0 END) AS TotalIncome,
            SUM(CASE WHEN TransactionType = 1 THEN AmountInSp ELSE 0 END) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID
        GROUP BY CategoryID
    ),
    -- 2. Get global income separately (since income isn't usually tied to a category)
    GlobalIncome AS (
        SELECT SUM(AmountInSp) as OverallIncome 
        FROM [Ledger].[Transactions] 
        WHERE UserID = @UserID AND TransactionType = 0
    )
    
    SELECT
        b.BudgetID,
        b.UserID,
        b.CategoryID,
        b.PercentageLimit,
        b.StartDate,
        b.EndDate,
        b.IsActive,

        -- The "Allowance" in currency (e.g., $300)
        CAST((gi.OverallIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        -- The "Actual Spent" in currency (e.g., $30)
        COALESCE(ut.TotalSpent, 0) AS SpendingProgress,
        -- The Percentage of the Budget used (e.g., 10%)
        CAST(
            CASE 
                WHEN gi.OverallIncome > 0 AND b.PercentageLimit > 0 
                THEN (COALESCE(ut.TotalSpent, 0) / (gi.OverallIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0 
            END AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS JOIN GlobalIncome gi
    LEFT JOIN UserTotals ut ON b.CategoryID = ut.CategoryID
    WHERE b.UserID = @UserID;
END
