CREATE TABLE [Ledger].[Incomes] (
    [IncomeID] INT             NOT NULL,
    [UserID]   INT             NOT NULL,
    [Title]    NVARCHAR(255)    NOT NULL,
    [TagID]    INT             NULL,
    [WalletID] INT             NOT NULL,
    [Amount]   DECIMAL (18, 2) NOT NULL,
    [Date]     DATETIME        DEFAULT (getdate()) NOT NULL,

    PRIMARY KEY CLUSTERED ([IncomeID] ASC),
    CONSTRAINT [FK_Incomes_Transactions] FOREIGN KEY ([IncomeID]) 
        REFERENCES [Ledger].[Transactions] ([TransactionID]) ON DELETE CASCADE,
    CONSTRAINT [CHK_Incomes_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_Incomes_Tags] FOREIGN KEY ([TagID]) REFERENCES [Config].[Tags] ([TagID]),
    CONSTRAINT [FK_Incomes_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [FK_Incomes_Wallets] FOREIGN KEY ([WalletID]) REFERENCES [Banking].[Wallets] ([WalletID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Incomes_User_Date]
    ON [Ledger].[Incomes]([UserID] ASC, [Date] DESC)
    INCLUDE([Amount], [WalletID]);

