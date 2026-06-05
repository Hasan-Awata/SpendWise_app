CREATE PROCEDURE [Planning].[sp_DeleteFixedIncome]
    @FixedIncomeId INT,
    @UserId INT 
AS
BEGIN

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

           SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedIncomes] 
        WHERE FixedIncomeId = @FixedIncomeId;

         IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50012, 'The specified fixed income record was not found.', 1;
        END
        
          IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50013, 'Access denied. You do not own this fixed income record.', 1;
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN;

          DELETE FROM [Planning].[FixedIncomes]
        WHERE FixedIncomeId = @FixedIncomeId AND UserID = @UserId;

         DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

          SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
           IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END