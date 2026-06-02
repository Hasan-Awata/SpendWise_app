
-- ==========================================
-- Add Wallet (Strict Currency Link)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        -- 1. Explicitly verify the CurrencyId exists before inserting
        -- (Optional, but provides a clean error message that your new SqlExceptionHandler can catch!)
        IF NOT EXISTS (SELECT 1 FROM [Config].Currencies WHERE CurrencyID = @CurrencyId)
        BEGIN
            ;THROW 50001, 'The specified Currency ID does not exist.', 1; 
        END

        -- 2. Create the Wallet using the directly provided CurrencyId
        INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance, IsSaved)
        VALUES (@UserId, @CurrencyId, @Balance, @IsSaved);
        
        DECLARE @NewWalletID INT = SCOPE_IDENTITY();

        COMMIT TRAN; -- Lock Released: Operation succeeded
        
        -- Return the new WalletID to C#
        SELECT @NewWalletID;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
