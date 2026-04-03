use SpendWiseDB;
go


CREATE PROCEDURE [usr].[sp_IsUsernameExist]
	@Username NVARCHAR(100)
AS
BEGIN
	SELECT found = 1 from Users where Username = @Username;
END
GO

CREATE PROCEDURE [usr].[sp_GetByUsername]
	@Username NVARCHAR(100)
AS
BEGIN
	SELECT * from Users where Username = @Username;
END
GO
