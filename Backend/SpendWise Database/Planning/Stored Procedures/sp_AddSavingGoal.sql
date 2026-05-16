CREATE PROCEDURE [Planning].[sp_AddSavingGoal]
    @UserId INT,
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validation: Check if a saving goal with the same title already exists for this user
    -- Updated to [Planning].[SavingsGoals] to match your table definition file
    IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title)
        THROW 50006, 'A saving goal with this title already exists for the user.', 1;
   
    -- Validation: Target amount must be greater than zero
    IF @TargetAmount <= 0
        THROW 50007, 'The target amount must be greater than zero.', 1;

    -- Insertion into the SavingsGoals table
    INSERT INTO [Planning].[SavingsGoals] (UserID, Title, TargetAmount, CurrentAmount, DeadlineDate)
    VALUES (@UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate);
    
    -- Return the newly inserted ID to match ExecuteScalarAsync
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END