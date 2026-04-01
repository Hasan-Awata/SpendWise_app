CREATE PROCEDURE [cfg].[sp_GetTag]
	@TagID int
AS
BEGIN
	select * from cfg.Tags where TagID = @TagID;
END
GO

CREATE PROCEDURE [cfg].[sp_GetTagsByCategoryID]
	@UserID int, @CategoryID int
AS
BEGIN
	select * from cfg.Tags where UserID = @UserID AND CategoryID = @CategoryID;
END
GO