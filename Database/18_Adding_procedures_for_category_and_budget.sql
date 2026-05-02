
-- 1. Drop the dependent Check Constraint first
ALTER TABLE [Planning].[Budgets] 
DROP CONSTRAINT [CK__Budgets__Percent__6477ECF3];
GO

-- 2. Now it is safe to drop the static consumption percentage column
ALTER TABLE [Planning].[Budgets] 
DROP COLUMN [Percentage];
GO

-- 3. Rename LimitAmount to PercentageLimit for clarity
DECLARE @TableName NVARCHAR(256) = '[Planning].[Budgets]';
DECLARE @ColumnName NVARCHAR(128) = 'LimitAmount';
DECLARE @ConstraintName NVARCHAR(256);
DECLARE @SQL NVARCHAR(MAX);

-- 1. Find and Drop any DEFAULT Constraints attached to the column
SELECT @ConstraintName = obj.name
FROM sys.default_constraints obj
INNER JOIN sys.columns col ON obj.parent_object_id = col.object_id AND obj.parent_column_id = col.column_id
WHERE obj.parent_object_id = OBJECT_ID(@TableName) AND col.name = @ColumnName;

IF @ConstraintName IS NOT NULL
BEGIN
    SET @SQL = 'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT [' + @ConstraintName + ']';
    EXEC sp_executesql @SQL;
    PRINT 'Dropped Default Constraint: ' + @ConstraintName;
END

-- 2. Find and Drop any CHECK Constraints attached to the column
SET @ConstraintName = NULL;
SELECT @ConstraintName = obj.name
FROM sys.check_constraints obj
INNER JOIN sys.columns col ON obj.parent_object_id = col.object_id AND obj.parent_column_id = col.column_id
WHERE obj.parent_object_id = OBJECT_ID(@TableName) AND col.name = @ColumnName;

IF @ConstraintName IS NOT NULL
BEGIN
    SET @SQL = 'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT [' + @ConstraintName + ']';
    EXEC sp_executesql @SQL;
    PRINT 'Dropped Check Constraint: ' + @ConstraintName;
END

-- 3. Now perform the rename safely!
EXEC sp_rename 'Planning.Budgets.LimitAmount', 'PercentageLimit', 'COLUMN';
PRINT 'Column renamed successfully!';
GO

-- ==========================================
-- 1. Add Category Budget (Updated)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_AddCategoryBudget]
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
        THROW 2627, 'A budget for this category already exists for the user.', 1;

    INSERT INTO [Planning].[Budgets] (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
    VALUES (@UserID, @CategoryID, @PercentageLimit, @StartDate, @EndDate, @IsActive);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ==========================================
-- 2. Update Category Budget (Updated)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_UpdateCategoryBudget]
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
    IF NOT EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE BudgetID = @BudgetID AND UserID = @UserID)
        THROW 50003, 'Access denied. You do not own this budget.', 1;

    UPDATE [Planning].[Budgets]
    SET CategoryID = @CategoryID,
        PercentageLimit = @PercentageLimit,
        StartDate = @StartDate,
        EndDate = @EndDate,
        IsActive = @IsActive
    WHERE BudgetID = @BudgetID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetAllUserBudgets]
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
        -- Calculate Percentage Progress securely to avoid Divide By Zero
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
            -- Get Total Income (Type 0) in SYP during this budget period
            COALESCE((SELECT SUM(AmountInSp)
                      FROM [Ledger].[Transactions]
                      WHERE UserID = b.UserID AND TransactionType = 0
                      AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalIncome,

            -- Get Total Spent (Type 1) in SYP for this specific category during the budget period
            COALESCE((SELECT SUM(AmountInSp)
                      FROM [Ledger].[Transactions]
                      WHERE UserID = b.UserID AND CategoryID = b.CategoryID AND TransactionType = 1
                      AND TransactionDate BETWEEN b.StartDate AND b.EndDate), 0) AS TotalSpent
    ) AS Totals
    WHERE b.UserID = @UserID;
END
GO

-- ==========================================
-- 4. Get Single Budget (DYNAMIC CALCULATION)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetCategoryBudget]
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
GO