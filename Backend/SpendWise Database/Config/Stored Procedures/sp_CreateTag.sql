-- ==========================================
-- 1. Create Tag
-- ==========================================
CREATE   PROCEDURE [Config].[sp_CreateTag]
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate tag names for this specific user
    IF EXISTS (SELECT 1 FROM [Config].Tags WHERE UserID = @UserID AND Name = @Name)
    BEGIN
        THROW 50004, 'A tag with this name already exists for your account.', 1;
    END

    INSERT INTO [Config].Tags (UserID, Name)
    VALUES (@UserID, @Name);

    -- Return the new ID on success
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
