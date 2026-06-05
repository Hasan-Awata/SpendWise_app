CREATE TABLE [Config].[Categories] (
    [CategoryID] INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (100) NOT NULL,
    [Priority]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

