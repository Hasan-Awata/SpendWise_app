CREATE PROCEDURE [Banking].[sp_GetWalletsByCurrencyId]
	@UserId		INT,
	@CurrencyId INT
AS
BEGIN
	SELECT * FROM [Banking].Wallets 
	WHERE UserID = @UserID AND CurrencyID = @CurrencyID;
END