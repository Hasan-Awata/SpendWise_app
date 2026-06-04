CREATE PROCEDURE [Planning].[sp_UpdateFixedIncome]
    @FixedIncomeId INT,
    @UserId INT, 
    @WalletId INT, 
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
         IF NOT EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] 
                       WHERE FixedIncomeId = @FixedIncomeId 
                         AND UserID = @UserId)
        BEGIN
            ;THROW 50012, 'The specified fixed income record was not found or access denied.', 1;
        END

        IF @Amount <= 0
        BEGIN
            ;THROW 50013, 'The amount must be greater than zero.', 1;
        END

         IF EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] 
                   WHERE UserID = @UserId 
                     AND WalletId = @WalletId 
                     AND Title = @Title 
                     AND FixedIncomeId <> @FixedIncomeId)
        BEGIN
            ;THROW 50011, 'A fixed income with this title already exists in the selected wallet.', 1;
        END

        UPDATE [Planning].[FixedIncomes]
        SET Title = @Title,
            Amount = @Amount,
            IsMonthly = @IsMonthly,
            IsActive = @IsActive,
            Days = @Days,
            LastTime = ISNULL(@LastTime, LastTime),
            WalletId = @WalletId 
        WHERE FixedIncomeId = @FixedIncomeId 
          AND UserID = @UserId;
        
        SELECT @@ROWCOUNT AS RowsAffected;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END