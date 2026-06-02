CREATE TABLE [Banking].[Wallets] (
    [WalletID]   INT             IDENTITY (1, 1) NOT NULL,
    [UserID]     INT             NOT NULL,
    [CurrencyID] INT             NOT NULL,
    [Balance]    DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsSaved]    BIT             NOT NULL,
    PRIMARY KEY CLUSTERED ([WalletID] ASC),
    CONSTRAINT [CHK_Wallets_Balance] CHECK ([Balance]>=(0)),
    CONSTRAINT [FK_Wallets_Currencies] FOREIGN KEY ([CurrencyID]) REFERENCES [Config].[Currencies] ([CurrencyID]),
    CONSTRAINT [FK_Wallets_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [UQ_Wallets_UserCurrencySaved] UNIQUE NONCLUSTERED ([UserID] ASC, [CurrencyID] ASC, [IsSaved] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Wallets_UserCurrencySaved_Covering]
    ON [Banking].[Wallets]([UserID] ASC, [CurrencyID] ASC, [IsSaved] ASC)
    INCLUDE([Balance]);

