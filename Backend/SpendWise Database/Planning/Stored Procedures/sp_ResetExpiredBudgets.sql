CREATE PROCEDURE [Planning].[sp_ResetExpiredBudgets]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Capture the expiring budgets and the users' device tokens first
        SELECT 
            b.BudgetID,
            u.FcmToken,
            b.PercentageLimit
        INTO #TempExpiredBudgets
        FROM [Planning].Budgets b
        INNER JOIN [Identity].Users u ON b.UserID = u.UserID
        WHERE b.IsActive = 1 
          AND b.EndDate <= CAST(GETDATE() AS DATE)
          AND u.FcmToken IS NOT NULL; -- Only care about users with active devices

        -- 2. Perform the date-rolling update
        UPDATE Budgets
        SET 
            StartDate = DATEADD(day, DATEDIFF(day, StartDate, EndDate), StartDate),
            EndDate = DATEADD(day, DATEDIFF(day, StartDate, EndDate), EndDate)
        WHERE IsActive = 1 
          AND EndDate <= CAST(GETDATE() AS DATE);

        -- 3. Return the data to your ASP.NET Core background worker
        SELECT PercentageLimit, FcmToken FROM #TempExpiredBudgets;

        DROP TABLE #TempExpiredBudgets;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO