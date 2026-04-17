CREATE OR ALTER PROCEDURE Config.sp_CreateTag
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check for duplicate tag names for this specific user
        IF EXISTS (SELECT 1 FROM Config.Tags WHERE UserID = @UserID AND Name = @Name)
        BEGIN
            THROW 50001, 'A tag with this name already exists for this user.', 1;
        END

        INSERT INTO Config.Tags(UserID, Name)
        VALUES (@UserID, @Name);

        -- Return the new ID on success
        SELECT CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Config.sp_UpdateTag
    @TagID INT,
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        UPDATE Config.Tags
        SET Name = @Name
        WHERE TagID = @TagID AND UserID = @UserID;

        -- Check if any rows were actually updated
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50002, 'Tag not found or you do not have permission to update it.', 1;
        END

		SELECT @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Config.sp_DeleteTag
    @TagID INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM Config.Tags
        WHERE TagID = @TagID;

        -- Check if any rows were actually deleted
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50003, 'Tag not found or already deleted.', 1;
        END
		SELECT @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Config.sp_GetTag
    @TagID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Config.Tags WHERE TagID = @TagID AND UserID = @UserID)
        BEGIN
            THROW 50004, 'Tag not found.', 1;
        END

        SELECT TagID, UserID, Name
        FROM Config.Tags
        WHERE TagID = @TagID AND UserID = @UserID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Config.sp_GetTags
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM Config.Tags
    WHERE UserID = @UserID;
END
GO