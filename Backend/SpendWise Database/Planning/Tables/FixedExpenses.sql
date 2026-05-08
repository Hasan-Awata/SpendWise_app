CREATE TABLE [Planning].[FixedExpenses] (
    [FixedExpenseID] INT             IDENTITY (1, 1) NOT NULL,
    [UserID]         INT             NOT NULL,
    [CategoryID]     INT             NOT NULL,
    [Title]          NVARCHAR (200)  NOT NULL,
    [Amount]         DECIMAL (18, 2) NOT NULL,
    [DueDate]        DATE            NOT NULL,
    [IsActive]       BIT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([FixedExpenseID] ASC),
    CONSTRAINT [CHK_FixedExpenses_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_FixedExpenses_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [Config].[Categories] ([CategoryID]),
    CONSTRAINT [FK_FixedExpenses_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [UQ_FixedExpenses_UserTitle] UNIQUE NONCLUSTERED ([UserID] ASC, [Title] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_FixedExpenses_User_DueDate]
    ON [Planning].[FixedExpenses]([UserID] ASC, [DueDate] ASC)
    INCLUDE([Amount], [Title], [CategoryID]) WHERE ([IsActive]=(1));

