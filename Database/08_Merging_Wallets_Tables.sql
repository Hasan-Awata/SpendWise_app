DROP TABLE Banking.SavedWallets;

ALTER TABLE Banking.Wallets ADD IsSaved BIT;
ALTER TABLE Banking.Wallets ALTER COLUMN IsSaved BIT NOT NULL;
