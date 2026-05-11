CREATE TABLE [Config].[Tags] (
    [TagID]  INT            IDENTITY (1, 1) NOT NULL,
    [UserID] INT            NOT NULL,
    [Name]   NVARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([TagID] ASC),
    CONSTRAINT [FK_Tags_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    CONSTRAINT [UQ_Tags_UserName] UNIQUE NONCLUSTERED ([UserID] ASC, [Name] ASC)
);

