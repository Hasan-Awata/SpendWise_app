CREATE TABLE [Planning].[SharedDebts] (
    [DebtID]     INT             IDENTITY (1, 1) NOT NULL,
    [CreditorID] INT             NOT NULL,
    [DebtorID]   INT             NOT NULL,
    [Amount]     DECIMAL (18, 2) NOT NULL,
    [Title]      NVARCHAR (200)  NOT NULL,
    [Status]     NVARCHAR (50)   NOT NULL,
    [CreatedAt]  DATETIME        DEFAULT (getdate()) NOT NULL,
    [DueDate]    DATETIME        NULL,
    [CreditorWalletID] INT NULL, 
    [DebtorWalletID] INT NULL, 
    PRIMARY KEY CLUSTERED ([DebtID] ASC),
    CONSTRAINT [CHK_SharedDebts_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_SharedDebts_Creditor] FOREIGN KEY ([CreditorID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [FK_SharedDebts_Debtor] FOREIGN KEY ([DebtorID]) REFERENCES [Identity].[Users] ([UserID]), 
    CONSTRAINT [FK_SharedDebts_CreditorWallet] FOREIGN KEY ([CreditorWalletID]) REFERENCES [Banking].[Wallets]([WalletID]) ,
    CONSTRAINT [FK_SharedDebts_DebtorWallet] FOREIGN KEY ([DebtorWalletID]) REFERENCES [Banking].[Wallets]([WalletID]) 
);


GO
CREATE NONCLUSTERED INDEX [IX_SharedDebts_Debtor]
    ON [Planning].[SharedDebts]([DebtorID] ASC, [DueDate] ASC)
    INCLUDE([Amount], [CreditorID], [Status]);


GO
CREATE NONCLUSTERED INDEX [IX_SharedDebts_Creditor]
    ON [Planning].[SharedDebts]([CreditorID] ASC, [DueDate] ASC)
    INCLUDE([Amount], [DebtorID], [Status]);

