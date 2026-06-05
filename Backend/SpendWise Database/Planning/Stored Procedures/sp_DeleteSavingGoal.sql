CREATE PROCEDURE [Planning].[sp_DeleteSavingGoal]
    @GoalId INT
AS
BEGIN
    
    BEGIN TRY
         IF NOT EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId)
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found.', 1;
        END

         DELETE FROM [Planning].[SavingsGoals] 
        WHERE GoalID = @GoalId;
        
        
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO