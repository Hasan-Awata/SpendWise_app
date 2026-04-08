USE [SpendWiseDB]
GO

/****** Object:  Table [fin].[Expenses]    Script Date: 4/8/2026 2:23:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [fin].[Incomes](
	[IncomeID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Amount] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IncomeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [fin].[Incomes]  WITH CHECK ADD  CONSTRAINT [FK_Incomes_Users] FOREIGN KEY([UserID])
REFERENCES [usr].[Users] ([UserID])
GO

ALTER TABLE [fin].[Incomes] CHECK CONSTRAINT [FK_Incomes_Users]
GO

ALTER TABLE [fin].[Incomes]  WITH CHECK ADD  CONSTRAINT [CHK_Incomes_Amount] CHECK  (([Amount]>(0)))
GO

ALTER TABLE [fin].[Incomes] CHECK CONSTRAINT [CHK_Incomes_Amount]
GO


ALTER TABLE [fin].[Expenses] ADD Products NVARCHAR(1000)
ALTER TABLE [fin].[Expenses] ALTER COLUMN Products NVARCHAR(1000) NOT NULL

ALTER TABLE [pln].[Works] ADD IsActive BIT NOT NULL

ALTER TABLE [fin].[Transactions] ADD Title NVARCHAR(50) NOT NULL;
ALTER TABLE [fin].[Transactions] ADD IncomeID INT NULL CONSTRAINT 
FK_Transactions_Incomes FOREIGN KEY (IncomeID) REFERENCES [fin].[Incomes](IncomeID);


/****** Object:  StoredProcedure [fin].[sp_UpdateTransaction]    Script Date: 4/7/2026 5:56:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. Update (Update Transaction)
-- =============================================
ALTER PROCEDURE [fin].[sp_UpdateTransaction]
    @TransactionID INT,
    @Amount DECIMAL(18,2),
    @TransactionType INT,
	@Title NVARCHAR(50),
    @Description NVARCHAR(255) = NULL,
    @CategoryID INT = NULL,
    @TagID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- غالباً لا نسمح بتعديل الـ UserID والـ WalletID والمحاور الأساسية بعد إنشائها
    UPDATE fin.Transactions
    SET Amount = @Amount,
        TransactionType = @TransactionType,
		Title = @Title,
        Description = @Description,
        CategoryID = @CategoryID,
        TagID = @TagID
    WHERE TransactionID = @TransactionID;
END

/****** Object:  StoredProcedure [fin].[sp_CreateTransaction]    Script Date: 4/7/2026 2:15:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 1. Create (Insert Transaction)
-- =============================================
ALTER PROCEDURE [fin].[sp_CreateTransaction]
    @UserID INT,
    @WalletID INT,
    @Amount DECIMAL(18,2),
    @TransactionType INT,
	@Title NVARCHAR(50),
    @Description NVARCHAR(255) = NULL,
    @CategoryID INT = NULL,
    @TagID INT = NULL,
    @GoalID INT = NULL,
    @ObligationID INT = NULL,
    @DebtID INT = NULL,
    @WorkID INT = NULL,
    @ExpenseID INT = NULL,
    @NewTransactionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO fin.Transactions 
        (UserID, WalletID, Amount, TransactionDate, TransactionType,Title, Description, CategoryID, TagID, GoalID, ObligationID, DebtID, WorkID, ExpenseID)
    VALUES 
        (@UserID, @WalletID, @Amount, GETDATE(), @TransactionType,@Title, @Description, @CategoryID, @TagID, @GoalID, @ObligationID, @DebtID, @WorkID, @ExpenseID);
    
    SET @NewTransactionID = SCOPE_IDENTITY();
END
