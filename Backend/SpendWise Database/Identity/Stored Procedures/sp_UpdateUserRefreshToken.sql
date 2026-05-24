CREATE PROCEDURE [Identity].[sp_UpdateUserRefreshToken]
	@RefreshToken NVARCHAR (255) = NULL,
	@RefreshTokenExpiryTime DATETIME = NULL,
    @UserId INT
AS
BEGIN
    UPDATE [Identity].[Users]
    SET RefreshToken = @RefreshToken,
        RefreshTokenExpiryTime = @RefreshTokenExpiryTime
    WHERE UserID = @UserId;
END
