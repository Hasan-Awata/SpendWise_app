CREATE TABLE [Planning].[FixedExpenses] (
    [FixedExpenseID] INT             IDENTITY (1, 1) NOT NULL,
    [UserID]         INT             NOT NULL,
    [WalletId]       INT             NOT NULL, 
    [Title]          NVARCHAR (200)  NOT NULL,
    [Amount]         DECIMAL (18, 2) NOT NULL,
    [IsMonthly]      BIT             NOT NULL, 
    [IsActive]       BIT             DEFAULT ((1)) NOT NULL,
    [Days]           INT             NULL,    
    [LastTime]       DATETIME        NULL,     
    
    PRIMARY KEY CLUSTERED ([FixedExpenseID] ASC),
    CONSTRAINT [CHK_FixedExpenses_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [FK_FixedExpenses_Users] FOREIGN KEY ([UserID]) REFERENCES [Identity].[Users] ([UserID]),
    
    -- قيد الربط مع جدول المحافظ (تأكد من اسم جدول المحافظ لديك في الـ Schema، هنا افترضت أنه Config.Wallets)
    CONSTRAINT [FK_FixedExpenses_Wallets] FOREIGN KEY ([WalletId]) REFERENCES [Banking].[Wallets] ([WalletId]),
    
    -- تم تحديث القيد الفريد ليشمل المحفظة مع المستخدم والعنوان لضمان عدم التكرار داخل نفس المحفظة فقط
    CONSTRAINT [UQ_FixedExpenses_UserWalletTitle] UNIQUE NONCLUSTERED ([UserID] ASC, [WalletId] ASC, [Title] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_FixedExpenses_User_Active]
    ON [Planning].[FixedExpenses]([UserID] ASC)
    INCLUDE([Amount], [Title], [WalletId], [IsMonthly], [Days], [LastTime]) 
    WHERE ([IsActive]=(1));
GO