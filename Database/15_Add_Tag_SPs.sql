USE SpendWiseDB;
GO

-- ==========================================
-- 1. Create Tag
-- ==========================================
CREATE OR ALTER PROCEDURE [Config].[sp_CreateTag]
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate tag names for this specific user
    IF EXISTS (SELECT 1 FROM [Config].Tags WHERE UserID = @UserID AND Name = @Name)
    BEGIN
        -- We will let this throw 50001 so the global handler catches it
        THROW 50001, 'A tag with this name already exists for your account.', 1;
    END

    INSERT INTO [Config].Tags (UserID, Name)
    VALUES (@UserID, @Name);

    -- Return the new ID on success
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ==========================================
-- 2. Update Tag (Secured)
-- ==========================================
CREATE OR ALTER PROCEDURE [Config].[sp_UpdateTag]
    @TagID INT,
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    UPDATE [Config].Tags
    SET Name = @Name
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 3. Delete Tag (Secured)
-- ==========================================
CREATE OR ALTER PROCEDURE [Config].[sp_DeleteTag]
    @TagID INT,
    @UserID INT -- Added IDOR Security
AS
BEGIN
    SET NOCOUNT ON;

    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    DELETE FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- ==========================================
-- 4. Get Tag By ID
-- ==========================================
CREATE OR ALTER PROCEDURE [Config].[sp_GetTag]
    @TagID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;
END
GO

-- ==========================================
-- 5. Get All Tags By User
-- ==========================================
CREATE OR ALTER PROCEDURE [Config].[sp_GetTags]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE UserID = @UserID;
END
GO