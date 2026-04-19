USE SpendWiseDB;
GO

-- ==========================================
-- 1. Add User (Optimized and Secured)
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_AddUser]
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
GO

-- ==========================================
-- 2. Get User By Username (For Login)
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password
    FROM [Identity].Users
    WHERE Username = @Username;
END
GO

-- ==========================================
-- 3. Get User By ID (For Session Management)
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password
    FROM [Identity].Users
    WHERE UserID = @UserId;
END
GO

-- ==========================================
-- 4. Check if Username Exists (Optimized)
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_CheckUsernameExists]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Returns a simple boolean (1 or 0) for C# to read via ExecuteScalarAsync
    IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        SELECT CAST(1 AS BIT);
    ELSE
        SELECT CAST(0 AS BIT);
END
GO