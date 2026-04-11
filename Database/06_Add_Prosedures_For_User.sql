USE SpendWiseDB;
GO

-- ==========================================
-- 1. Add User
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_AddUser]
	@NewUserID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [Identity].Users (FirstName, LastName, Username, Password)
    VALUES (@FirstName, @LastName, @Username, @Password);
    
    -- Return the newly generated UserID
    SET @NewUserID = CAST(SCOPE_IDENTITY() AS INT);
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
-- 4. Check if Username Exists (For Registration Validation)
-- ==========================================
CREATE OR ALTER PROCEDURE [Identity].[sp_CheckUsernameExists]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Returns 1 (True) if it exists, 0 (False) if it does not
    IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        SELECT CAST(1 AS BIT);
    ELSE
        SELECT CAST(0 AS BIT);
END
GO