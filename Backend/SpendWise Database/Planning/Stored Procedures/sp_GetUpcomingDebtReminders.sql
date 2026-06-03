CREATE PROCEDURE [Planning].[sp_GetUpcomingDebtReminders]
AS
BEGIN
    SET NOCOUNT ON;

    -- Fetch unpaid or partially paid debts due in exactly 2 days
    SELECT 
        sd.Title,
        (sd.Amount - sd.PaidAmount) AS RemainingAmount,
        u.FcmToken
    FROM [Planning].SharedDebts sd
    INNER JOIN [Identity].Users u ON sd.DebtorID = u.UserID
    WHERE sd.PaidAmount < sd.Amount
      AND u.FcmToken IS NOT NULL
      -- DATEDIFF ensures we match exactly 2 calendar days away regardless of time of day
      AND DATEDIFF(day, CAST(GETDATE() AS DATE), CAST(sd.DueDate AS DATE)) = 2;
END
GO