CREATE PROCEDURE [Planning].[sp_CreateFixedExpense]
    @OwnerId INT,
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @DueDate DATE,
    @IsActive BIT,
    @CategoryId INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @OwnerId AND Title = @Title)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user.', 1;
        END

        BEGIN TRAN;

        INSERT INTO [Planning].[FixedExpenses] 
            (UserID, CategoryID, Title, Amount, DueDate, IsActive)
        VALUES 
            (@OwnerId, @CategoryId, @Title, @Amount, @DueDate, @IsActive);
        
        DECLARE @NewID INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRAN;

        SELECT @NewID AS NewID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END