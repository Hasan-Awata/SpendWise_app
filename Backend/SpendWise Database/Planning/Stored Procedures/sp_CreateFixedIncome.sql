

CREATE PROCEDURE [Planning].[sp_CreateFixedIncome]
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
       
        IF @Amount <= 0
        BEGIN
            ;THROW 50010, 'The income amount must be greater than zero.', 1;
        END

          IF EXISTS (SELECT 1 FROM [Planning].[FixedIncomes] WHERE UserID = @UserId AND Title = @Title)
        BEGIN
            ;THROW 50011, 'A fixed income with this title already exists for the user.', 1;
        END

      
        BEGIN TRAN;

           INSERT INTO [Planning].[FixedIncomes] 
            (UserID, Title, Amount, IsMonthly, IsActive, Days, LastTime)
        VALUES 
            (@UserId, @Title, @Amount, @IsMonthly, @IsActive, @Days, ISNULL(@LastTime, GETDATE()));
           DECLARE @NewFixedIncomeID INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRAN;

          SELECT @NewFixedIncomeID AS NewFixedIncomeID;

    END TRY
    BEGIN CATCH
          IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END