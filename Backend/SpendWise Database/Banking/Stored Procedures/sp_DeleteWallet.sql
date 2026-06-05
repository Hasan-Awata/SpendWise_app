
-- ==========================================
-- 5. Delete a Wallet
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_DeleteWallet]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    DELETE FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
    
    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
