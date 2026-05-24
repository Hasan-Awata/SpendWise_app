
-- ==========================================
-- 3. Delete Tag (Secured)
-- ==========================================
CREATE   PROCEDURE [Config].[sp_DeleteTag]
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
