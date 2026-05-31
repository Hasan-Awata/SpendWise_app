CREATE PROCEDURE [Planning].[sp_GetSharedDebtByTitle]
	@Title NVARCHAR(200)
AS
BEGIN
	SELECT * FROM [Planning].[SharedDebts] WHERE [Title] = @Title;
END
GO