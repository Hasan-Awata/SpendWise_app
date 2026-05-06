
-- ==========================================
-- 5. Delete Single Budget 
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_DeleteCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    DELETE FROM [Planning].Budgets 
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
