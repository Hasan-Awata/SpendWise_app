CREATE PROCEDURE [Identity].[sp_UpdateUserFcmToken]
    @UserID INT,
    @FcmToken NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Attempt the update
        UPDATE [Identity].Users
        SET FcmToken = @FcmToken
        WHERE UserID = @UserID;

        -- Check how many rows were actually affected
        IF @@ROWCOUNT = 0
        BEGIN
            -- The query ran, but no user was found with that ID
            SELECT 
                CAST(0 AS BIT) AS IsSuccess
        END
        ELSE
        BEGIN
            -- Successfully updated the row
            SELECT 
                CAST(1 AS BIT) AS IsSuccess
        END
    END TRY
    BEGIN CATCH
        -- A fatal SQL error occurred
        SELECT 
            CAST(0 AS BIT) AS IsSuccess
    END CATCH
END
GO