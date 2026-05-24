CREATE FUNCTION [Planning].[fn_IsOverCategoryBudget]
(
    @UserID INT,
    @CategoryID INT,
    @ReferenceDate DATETIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsOver BIT = 0;
    DECLARE @TotalIncome DECIMAL(18,2);
    DECLARE @TotalSpent DECIMAL(18,2);
    DECLARE @PercentLimit DECIMAL(18,2);

    -- Get the budget details for this category and date
    SELECT TOP 1 
        @PercentLimit = PercentageLimit,
        @TotalIncome = (
            SELECT COALESCE(SUM(AmountInSp), 0) 
            FROM [Ledger].[Transactions] 
            WHERE UserID = b.UserID AND TransactionType = 0 
            AND TransactionDate BETWEEN b.StartDate AND b.EndDate
        ),
        @TotalSpent = (
            SELECT COALESCE(SUM(AmountInSp), 0) 
            FROM [Ledger].[Transactions] 
            WHERE UserID = b.UserID AND CategoryID = b.CategoryID AND TransactionType = 1 
            AND TransactionDate BETWEEN b.StartDate AND b.EndDate
        )
    FROM [Planning].[Budgets] b
    WHERE b.UserID = @UserID 
      AND b.CategoryID = @CategoryID 
      AND b.IsActive = 1
      AND @ReferenceDate BETWEEN b.StartDate AND b.EndDate;

    -- Calculation logic
    IF @TotalIncome > 0 AND @PercentLimit > 0
    BEGIN
        IF @TotalSpent > (@TotalIncome * (@PercentLimit / 100.0))
            SET @IsOver = 1;
    END

    RETURN @IsOver;
END