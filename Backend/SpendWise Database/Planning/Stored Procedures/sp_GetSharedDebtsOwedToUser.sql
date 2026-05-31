CREATE PROCEDURE [dbo].[sp_GetSharedDebtsOwedToUser]
	@UserId INT
AS
	SELECT * FROM [Planning].[SharedDebts] WHERE [CreditorID] = @UserId;
RETURN 0
