CREATE PROCEDURE [Planning].[sp_CreateFixedExpense]
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
         IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @UserId AND WalletId = @WalletId AND Title = @Title)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user in this wallet.', 1;
        END

        BEGIN TRAN;

        INSERT INTO [Planning].[FixedExpenses] (UserID, WalletId, Title, Amount, IsMonthly, IsActive, Days, LastTime)
        VALUES (@UserId, @WalletId, @Title, @Amount, @IsMonthly, @IsActive, @Days, @LastTime);

        DECLARE @NewId INT = SCOPE_IDENTITY();

        COMMIT TRAN;

        SELECT @NewId AS NewId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO