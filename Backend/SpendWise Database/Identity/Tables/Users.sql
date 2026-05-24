CREATE TABLE [Identity].[Users] (
    [UserID]    INT            IDENTITY (1, 1) NOT NULL,
    [FirstName] NVARCHAR (100) NOT NULL,
    [LastName]  NVARCHAR (100) NOT NULL,
    [Username]  NVARCHAR (100) NOT NULL,
    [Password]  NVARCHAR (255) NOT NULL,
    [RefreshToken] NVARCHAR (255) NULL,
    [RefreshTokenExpiryTime] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_Users_Username] UNIQUE NONCLUSTERED ([Username] ASC)
);

