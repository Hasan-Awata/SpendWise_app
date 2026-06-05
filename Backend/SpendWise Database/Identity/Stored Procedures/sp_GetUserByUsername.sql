
-- ==========================================
-- 2. Get User By Username (For Login)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password, RefreshToken, RefreshTokenExpiryTime
    FROM [Identity].Users
    WHERE Username = @Username;
END
