CREATE PROCEDURE [Banking].[sp_GetUserWalletsPair]
	@WalletId INT,
	@UserId	 INT
AS
BEGIN
SET NOCOUNT ON;

    SELECT 
        w2.WalletID,
        w2.UserId,
        w2.CurrencyID,
        w2.Balance,
        w2.IsSaved
    FROM [Banking].Wallets w1
    INNER JOIN [Banking].Wallets w2 ON w1.UserId = w2.UserId AND w1.CurrencyId = w2.CurrencyId
    WHERE w1.WalletID = @WalletId;
END;