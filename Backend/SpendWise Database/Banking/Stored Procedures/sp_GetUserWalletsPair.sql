CREATE PROCEDURE [Banking].[sp_GetUserWalletsPair]
	@WalletId INT,
	@UserId	 INT
AS
BEGIN
SET NOCOUNT ON;

    SELECT 
        w2.WalletID,
        w2.UserID,
        w2.CurrencyID,
        w2.Balance,
        w2.IsSaved
    FROM [Banking].Wallets w1
    INNER JOIN [Banking].Wallets w2 ON w1.UserID = w2.UserID AND w1.CurrencyID = w2.CurrencyID
    WHERE w1.WalletID = @WalletId;
END;