CREATE TABLE [Planning].[SavingsGoals] (
    [GoalID]        INT             IDENTITY (1, 1) NOT NULL,
    [UserID]        INT             NOT NULL,
    [Title]         NVARCHAR (200)  NOT NULL,
    [TargetAmount]  DECIMAL (18, 2) NOT NULL,
    [CurrentAmount] DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DeadlineDate]  DATE            NULL,
    [IsAchieved]    BIT             DEFAULT ((0)) NOT NULL,
    [CurrencyID]    INT             NOT NULL,
    PRIMARY KEY CLUSTERED ([GoalID] ASC),
    CONSTRAINT [CHK_SavingsGoals_CurrentAmount] CHECK ([CurrentAmount]>=(0)),
    CONSTRAINT [CHK_SavingsGoals_TargetAmount] CHECK ([TargetAmount]>(0)),
    CONSTRAINT [FK_SavingGoals_SeedCurrencies] FOREIGN KEY ([CurrencyID]) REFERENCES [Config].[Currencies] ([CurrencyID]),
    CONSTRAINT [FK_SavingsGoals_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SavingsGoals_ActiveTitle]
    ON [Planning].[SavingsGoals]([UserID] ASC, [Title] ASC) WHERE ([IsAchieved]=(0));

