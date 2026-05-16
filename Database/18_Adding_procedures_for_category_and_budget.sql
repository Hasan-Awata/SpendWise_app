
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
        THROW 50004, 'A budget for this category already exists for the user.', 1;

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
GO

-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetAllUserBudgets]
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

-- ==========================================
-- 5. Delete Single Budget 
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_DeleteCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    DELETE FROM [Planning].Budgets 
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO