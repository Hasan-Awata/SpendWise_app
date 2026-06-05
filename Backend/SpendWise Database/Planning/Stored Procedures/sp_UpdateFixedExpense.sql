CREATE PROCEDURE [Planning].[sp_UpdateFixedExpense]
    @FixedExpenseID INT, 
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

        IF @Amount <= 0
        BEGIN
            ;THROW 50020, 'The expense amount must be greater than zero.', 1;
        END

        -- التحقق من عدم التكرار مع استثناء السجل الحالي أثناء التعديل
        IF EXISTS (SELECT 1 FROM [Planning].[FixedExpenses] WHERE UserID = @UserId AND WalletId = @WalletId AND Title = @Title AND FixedExpenseID <> @FixedExpenseID)
        BEGIN
            ;THROW 50021, 'A fixed expense with this title already exists for the user in this wallet.', 1;
        END

        BEGIN TRAN;

        UPDATE [Planning].[FixedExpenses]
        SET Title = @Title,
            Amount = @Amount,
            IsMonthly = @IsMonthly,
            IsActive = @IsActive,
            Days = @Days,
            LastTime = ISNULL(@LastTime, LastTime),
            WalletId = @WalletId
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