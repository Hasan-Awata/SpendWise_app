-- ==========================================
-- 1. Get Saving Goal By ID
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetSavingGoalById]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate,
		IsAchieved
    FROM [Planning].[SavingsGoals]
    WHERE GoalID = @GoalId;
END
GO

-- ==========================================
-- 2. Get All User Goals
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetAllUserGoals]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate,
		IsAchieved
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId
    ORDER BY DeadlineDate ASC;
END
GO

-- ==========================================
-- 3. Get Achieved Goals (Current >= Target)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetAchievedGoals]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate,
		IsAchieved
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId AND IsAchieved = 1
    ORDER BY DeadlineDate DESC;
END
GO

-- ==========================================
-- 4. Add Saving Goal
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_AddSavingGoal]
    @UserId INT,
    @Title NVARCHAR(255),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATETIME
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        DECLARE @NewGoalID INT;

        INSERT INTO [Planning].[SavingsGoals]
        (UserID, Title, TargetAmount, CurrentAmount, DeadlineDate)
        VALUES 
        (@UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate);
        
        SET @NewGoalID = SCOPE_IDENTITY();

        COMMIT TRAN; 
        SELECT @NewGoalID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- ==========================================
-- 5. Update Saving Goal (With IDOR Security)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_UpdateSavingGoal]
    @GoalId INT,
    @UserId INT,
    @Title NVARCHAR(255),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATETIME,
	@IsAchieved BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- STRICT SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        
        SELECT @ActualOwnerId = UserID 
        FROM [Planning].[SavingsGoals]
        WHERE GoalID = @GoalId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            THROW 50002, 'Saving goal record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            THROW 50003, 'Access denied. You do not own this saving goal.', 1;
        END

        BEGIN TRAN; 

        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate,
			IsAchieved = @IsAchieved
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 6. Delete Saving Goal
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_DeleteSavingGoal]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN; 
        
        DELETE FROM [Planning].[SavingsGoals]
        WHERE GoalID = @GoalId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 7. Check if Goal Exists
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_CheckSavingGoalExists]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(1) 
    FROM [Planning].[SavingsGoals]
    WHERE GoalID = @GoalId;
END
GO