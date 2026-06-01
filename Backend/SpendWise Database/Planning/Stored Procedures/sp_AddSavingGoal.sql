CREATE PROCEDURE [Planning].[sp_AddSavingGoal]
    @UserId INT,
    @Title NVARCHAR(200),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2) = 0, 
    @DeadlineDate DATE = NULL,
    @CurrencyId INT,
    @IsAchieved BIT = 0,
    @NewGoalID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [Planning].[SavingsGoals] (
            UserID, Title, TargetAmount, CurrentAmount, DeadlineDate, IsAchieved, CurrencyID
        )
        VALUES (
            @UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate, @IsAchieved, @CurrencyId
        );

        SET @NewGoalID = SCOPE_IDENTITY();

        SELECT @NewGoalID AS NewGoalID;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO