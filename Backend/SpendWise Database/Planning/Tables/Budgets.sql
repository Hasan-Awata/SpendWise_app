CREATE TABLE [Planning].[Budgets] (
    [BudgetID]        INT             IDENTITY (1, 1) NOT NULL,
    [UserID]          INT             NOT NULL,
    [CategoryID]      INT             NOT NULL,
    [PercentageLimit] DECIMAL (18, 2) NOT NULL,
    [StartDate]       DATE            NOT NULL,
    [EndDate]         DATE            NOT NULL,
    [IsActive]        BIT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([BudgetID] ASC),
    CONSTRAINT [FK_Budgets_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [Config].[Categories] ([CategoryID]),
    CONSTRAINT [FK_Budgets_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID])
);

GO
CREATE NONCLUSTERED INDEX [IX_Budgets_User_Category_Covering]
    ON [Planning].[Budgets]([UserID] ASC, [CategoryID] ASC)
    INCLUDE([PercentageLimit], [StartDate], [EndDate], [IsActive]);

