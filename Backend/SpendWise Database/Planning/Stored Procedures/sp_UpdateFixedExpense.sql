CREATE PROCEDURE [Planning].[sp_UpdateFixedExpense]
    @Id INT,
    @OwnerId INT,
    @Title NVARCHAR(200),
    @Amount DECIMAL(18,2),
    @DueDate DATE,
    @IsActive BIT,
    @CategoryId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @ActualOwnerId INT;

        SELECT @ActualOwnerId = UserID 
        FROM [Planning].[FixedExpenses] 
        WHERE FixedExpenseID = @Id;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50022, 'The specified fixed expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @OwnerId
        BEGIN
            ;THROW 50023, 'Access denied. You do not own this fixed expense record.', 1;
        END

        IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @OwnerId AND Title = @Title AND FixedExpenseID <> @Id)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user.', 1;
        END

        BEGIN TRAN;

        UPDATE [Planning].[FixedExpenses]
        SET Title = @Title,
            Amount = @Amount,
            DueDate = @DueDate,
            IsActive = @IsActive,
            CategoryID = ISNULL(@CategoryId, CategoryID)
        WHERE FixedExpenseID = @Id AND UserID = @OwnerId;

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN;

        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END