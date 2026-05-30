CREATE PROCEDURE [Planning].[sp_GetSharedDebtsForUser]
	@UserID INT
AS
BEGIN
	SELECT * FROM [Planning].[SharedDebts]
	WHERE [CreditorID] = @UserID OR [DebtorID] = @UserID;
END
GO