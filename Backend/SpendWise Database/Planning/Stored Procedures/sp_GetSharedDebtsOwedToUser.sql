CREATE PROCEDURE [Planning].[sp_GetSharedDebtsOwedToUser]
	@UserId INT
AS
	SELECT * FROM [Planning].[SharedDebts] WHERE [CreditorID] = @UserId;
RETURN 0
