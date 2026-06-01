CREATE PROCEDURE [Planning].[sp_RefuseSharedDebt]
	@DebtID INT
AS
	DECLARE @S NVARCHAR(50);
	SELECT @S = Status FROM Planning.SharedDebts WHERE DebtID = @DebtID

	IF (@S != 'Accepted' OR @S != 'Refused')
	BEGIN
		UPDATE Planning.SharedDebts
		SET Status = 'Refused'
		WHERE DebtID = @DebtID;
	END
RETURN 0
