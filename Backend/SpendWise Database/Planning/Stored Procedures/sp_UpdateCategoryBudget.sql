-- ==========================================
-- 2. Update Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_UpdateCategoryBudget]
    @BudgetID INT,
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE CategoryID = @CategoryID AND UserID = @UserID)
        THROW 50003, 'Access denied. You do not own this budget.', 1;

    UPDATE [Planning].[Budgets]
    SET PercentageLimit = @PercentageLimit,
        StartDate = @StartDate,
        EndDate = @EndDate,
        IsActive = @IsActive
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
