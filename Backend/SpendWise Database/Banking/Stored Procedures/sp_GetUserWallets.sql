
-- ==========================================
-- 2. Get All Wallets for a User (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetUserWallets]
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
    WHERE UserID = @UserId;
END
