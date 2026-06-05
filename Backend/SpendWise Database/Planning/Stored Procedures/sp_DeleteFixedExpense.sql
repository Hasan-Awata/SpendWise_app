CREATE PROCEDURE [Planning].[sp_DeleteFixedExpense]
    @FixedExpenseID INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

        SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedExpenses] 
        WHERE FixedExpenseID = @FixedExpenseID;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50022, 'The specified fixed expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50023, 'Access denied. You do not own this fixed expense record.', 1;
        END

        BEGIN TRAN;

        DELETE FROM [Planning].[FixedExpenses]
        WHERE FixedExpenseID = @FixedExpenseID AND UserID = @UserId;

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO