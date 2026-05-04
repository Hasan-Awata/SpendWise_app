-- 1. Drop the old constraint that is causing the error
ALTER TABLE Banking.Wallets
DROP CONSTRAINT UQ_Wallets_UserCurrency;

-- 2. Add the correct constraint (if you haven't successfully added it yet)
-- This one correctly checks all three columns!
ALTER TABLE Banking.Wallets
ADD CONSTRAINT UQ_Wallets_UserCurrencySaved UNIQUE (UserID, CurrencyID, IsSaved);