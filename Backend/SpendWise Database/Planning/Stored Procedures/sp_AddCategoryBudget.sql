-- ==========================================
-- 1. Add Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_AddCategoryBudget]
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE UserID = @UserID AND CategoryID = @CategoryID)
        THROW 50004, 'A budget for this category already exists for the user.', 1;
   
   IF (SELECT ISNULL(SUM(PercentageLimit), 0) + @PercentageLimit FROM [Planning].[Budgets] WHERE UserID = @UserID) > 100
    THROW 50005, 'Wrong input, total categories budget percentage cannot exceed 100%.', 1;

    INSERT INTO [Planning].[Budgets] (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
    VALUES (@UserID, @CategoryID, @PercentageLimit, @StartDate, @EndDate, @IsActive);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
