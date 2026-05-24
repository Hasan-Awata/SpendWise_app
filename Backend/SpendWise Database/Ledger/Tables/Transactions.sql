CREATE TABLE [Ledger].[Transactions] (
    [TransactionID]   INT             IDENTITY (1, 1) NOT NULL,
    [UserID]          INT             NOT NULL,
    [WalletID]        INT             NOT NULL,
    [CategoryID]      INT             NULL,
    [TagID]           INT             NULL,
    [GoalID]          INT             NULL,
    [FixedExpenseID]  INT             NULL,
    [DebtID]          INT             NULL,
    [FixedIncomeID]   INT             NULL,
    [Title]           NVARCHAR (255)  NOT NULL,
    [Amount]          DECIMAL (18, 2) NOT NULL,
    [TransactionDate] DATETIME        DEFAULT (getdate()) NOT NULL,
    [TransactionType] INT             NOT NULL,
    [Description]     NVARCHAR (MAX)  NULL,
    [AmountInSp]      DECIMAL (18, 2) DEFAULT ((0.00)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TransactionID] ASC),
    CONSTRAINT [CHK_Transactions_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_Transactions_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [Config].[Categories] ([CategoryID]),
    CONSTRAINT [FK_Transactions_FixedExpenses] FOREIGN KEY ([FixedExpenseID]) REFERENCES [Planning].[FixedExpenses] ([FixedExpenseID]),
    CONSTRAINT [FK_Transactions_FixedIncomes] FOREIGN KEY ([FixedIncomeID]) REFERENCES [Planning].[FixedIncomes] ([FixedIncomeID]),
    CONSTRAINT [FK_Transactions_SavingsGoals] FOREIGN KEY ([GoalID]) REFERENCES [Planning].[SavingsGoals] ([GoalID]),
    CONSTRAINT [FK_Transactions_SharedDebts] FOREIGN KEY ([DebtID]) REFERENCES [Planning].[SharedDebts] ([DebtID]),
    CONSTRAINT [FK_Transactions_Tags] FOREIGN KEY ([TagID]) REFERENCES [Config].[Tags] ([TagID]),
    CONSTRAINT [FK_Transactions_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [FK_Transactions_Wallets] FOREIGN KEY ([WalletID]) REFERENCES [Banking].[Wallets] ([WalletID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Transactions_User_Date]
    ON [Ledger].[Transactions]([UserID] ASC, [TransactionDate] DESC)
    INCLUDE([Amount], [TransactionType], [CategoryID], [WalletID], [Title]);


GO
CREATE NONCLUSTERED INDEX [IX_Transactions_Wallet]
    ON [Ledger].[Transactions]([WalletID] ASC, [TransactionDate] DESC)
    INCLUDE([Amount], [TransactionType]);

