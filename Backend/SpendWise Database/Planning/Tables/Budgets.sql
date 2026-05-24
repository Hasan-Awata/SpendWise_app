CREATE TABLE [Planning].[Budgets] (
    [BudgetID]        INT             IDENTITY (1, 1) NOT NULL,
    [UserID]          INT             NOT NULL,
    [CategoryID]      INT             NOT NULL,
    [PercentageLimit] DECIMAL (18, 2) NOT NULL,
    [StartDate]       DATE            NOT NULL,
    [EndDate]         DATE            NOT NULL,
    [IsActive]        BIT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([BudgetID] ASC),
    CONSTRAINT [CHK_Budgets_Dates] CHECK ([StartDate]<[EndDate]),
    CONSTRAINT [FK_Budgets_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [Config].[Categories] ([CategoryID]),
    CONSTRAINT [FK_Budgets_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Budgets_ActiveCategory]
    ON [Planning].[Budgets]([UserID] ASC, [CategoryID] ASC) WHERE ([IsActive]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_Budgets_User_Dates]
    ON [Planning].[Budgets]([UserID] ASC, [StartDate] ASC, [EndDate] ASC)
    INCLUDE([CategoryID], [PercentageLimit]);

