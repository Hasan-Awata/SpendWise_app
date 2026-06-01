CREATE PROCEDURE [Planning].[sp_GetSharedDebtsIHaveToPay]
	@UserId INT
AS
	SELECT * FROM [Planning].[SharedDebts] WHERE [DebtorID] = @UserId;
RETURN 0