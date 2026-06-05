
-- ==========================================
-- 1. Get Wallet By ID (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetWalletById]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        WalletID, 
        Balance, 
        UserID, 
        IsSaved,
        CurrencyID
    FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
END
