CREATE TABLE [Planning].[FixedIncomes] (
    [FixedIncomeID] INT             IDENTITY (1, 1) NOT NULL,
    [UserID]        INT             NOT NULL,
    [Title]         NVARCHAR (200)  NOT NULL,
    [Amount]        DECIMAL (18, 2) NOT NULL,
    [IsMonthly]     BIT             DEFAULT ((1)) NOT NULL,
    [IsActive]      BIT             DEFAULT ((1)) NOT NULL,
    [Days]          INT             NULL,
    [LastTime]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([FixedIncomeID] ASC),
    CONSTRAINT [CHK_FixedIncomes_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_FixedIncomes_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [UQ_FixedIncomes_UserTitle] UNIQUE NONCLUSTERED ([UserID] ASC, [Title] ASC)
);

