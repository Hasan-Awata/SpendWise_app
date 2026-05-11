
-- ==========================================
-- 1. Add User (Optimized and Secured)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_AddUser]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Explicit duplicate username check
        IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        BEGIN
            -- This maps to your DuplicateResourceException in C#
            THROW 2627, 'This username is already taken.', 1; 
        END

        INSERT INTO [Identity].Users (FirstName, LastName, Username, Password)
        VALUES (@FirstName, @LastName, @Username, @Password);
        
        -- Return the newly generated UserID directly
        SELECT CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
