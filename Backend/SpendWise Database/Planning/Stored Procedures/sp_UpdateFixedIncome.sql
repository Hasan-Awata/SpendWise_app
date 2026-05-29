CREATE PROCEDURE [Planning].[sp_UpdateFixedIncome]
    @FixedIncomeId INT,
    @UserId INT, 
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @IsMonthly BIT,
    @IsActive BIT,
    @Days INT = NULL,
    @LastTime DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
        IF @Amount <= 0
        BEGIN
            ;THROW 50010, 'The income amount must be greater than zero.', 1;
        END
     IF EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] WHERE UserID = @UserId AND Title = @Title AND FixedIncomeId <> @FixedIncomeId)
        BEGIN
            ;THROW 50011, 'A fixed income with this title already exists for the user.', 1;
        END

        
        BEGIN TRAN;

        UPDATE [Planning].[FixedIncomes]
        SET Title = @Title,
            Amount = @Amount,
            IsMonthly = @IsMonthly,
            IsActive = @IsActive,
            Days = @Days,
            LastTime = ISNULL(@LastTime, GETDATE())
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