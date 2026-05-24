CREATE TABLE [Ledger].[Expenses] (
    [ExpenseID]  INT             NOT NULL,
    [UserID]     INT             NOT NULL,
    [Title]      NVARCHAR(255)    DEFAULT 'Expense',
    [TagID]      INT             NULL,
    [CategoryID] INT             NOT NULL,
    [WalletID]   INT             NOT NULL,
    [Products]   NVARCHAR (MAX)  NOT NULL,
    [Amount]     DECIMAL (18, 2) NOT NULL,
    [Date]       DATETIME        DEFAULT (getdate()) NOT NULL,

    PRIMARY KEY CLUSTERED ([ExpenseID] ASC),
    CONSTRAINT [FK_Expenses_Transactions] FOREIGN KEY ([ExpenseID]) 
        REFERENCES [Ledger].[Transactions] ([TransactionID]) ON DELETE CASCADE,
    CONSTRAINT [CHK_Expenses_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [CHK_Products_IsJSON] CHECK (Products IS NULL OR ISJSON(Products) = 1),
    CONSTRAINT [FK_Expenses_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [Config].[Categories] ([CategoryID]),
    CONSTRAINT [FK_Expenses_Tags] FOREIGN KEY ([TagID]) REFERENCES [Config].[Tags] ([TagID]),
    CONSTRAINT [FK_Expenses_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [FK_Expenses_Wallets] FOREIGN KEY ([WalletID]) REFERENCES [Banking].[Wallets] ([WalletID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Expenses_User_Date]
    ON [Ledger].[Expenses]([UserID] ASC, [Date] DESC)
    INCLUDE([Amount], [CategoryID], [WalletID]);

