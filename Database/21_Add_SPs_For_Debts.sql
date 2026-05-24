-- ==========================================
-- 1. Add Shared Debt
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_AddSharedDebt]
    @CreditorID INT,
    @DebtorID INT,
    @Amount DECIMAL(18,2),
    @Title NVARCHAR(255),
    @Status NVARCHAR(50),
    @CreatedAt DATETIME,
    @DueDate DATETIME
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        DECLARE @NewDebtID INT;

        INSERT INTO [Planning].[SharedDebts] 
        (CreditorID, DebtorID, Amount, Title, Status, CreatedAt, DueDate)
        VALUES 
        (@CreditorID, @DebtorID, @Amount, @Title, @Status, @CreatedAt, @DueDate);
        
        SET @NewDebtID = SCOPE_IDENTITY();

        COMMIT TRAN; 
        SELECT @NewDebtID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- ==========================================
-- 2. Update Shared Debt
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_UpdateSharedDebt]
    @DebtID INT,
    @CreditorID INT,
    @DebtorID INT,
    @Amount DECIMAL(18,2),
    @Title NVARCHAR(255),
    @Status NVARCHAR(50),
    @CreatedAt DATETIME,
    @DueDate DATETIME
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 

        UPDATE [Planning].[SharedDebts]
        SET CreditorID = @CreditorID,
            DebtorID = @DebtorID,
            Amount = @Amount,
            Title = @Title,
            Status = @Status,
            CreatedAt = @CreatedAt,
            DueDate = @DueDate
        WHERE DebtID = @DebtID;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 3. Delete Shared Debt By ID
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_DeleteSharedDebtById]
    @DebtID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        DELETE FROM [Planning].[SharedDebts]
        WHERE DebtID = @DebtID;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 4. Delete Shared Debt By Title
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_DeleteSharedDebtByTitle]
    @Title NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        DELETE FROM [Planning].[SharedDebts]
        WHERE Title = @Title;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- ==========================================
-- 5. Get Shared Debt By ID
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetSharedDebtById]
    @DebtID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DebtID, 
        CreditorID, 
        DebtorID, 
        Amount, 
        Title, 
        Status, 
        CreatedAt, 
        DueDate
    FROM [Planning].[SharedDebts]
    WHERE DebtID = @DebtID;
END
GO

-- ==========================================
-- 6. Get Shared Debt By Title
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetSharedDebtByTitle]
    @Title NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Using TOP 1 in case there are multiple debts with the same title,
    -- since the C# repository expects a single SharedDebt object to be mapped.
    SELECT TOP 1
        DebtID, 
        CreditorID, 
        DebtorID, 
        Amount, 
        Title, 
        Status, 
        CreatedAt, 
        DueDate
    FROM [Planning].[SharedDebts]
    WHERE Title = @Title;
END
GO

-- ==========================================
-- 7. Get Debts Owed TO User (User is Creditor)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetDebtsOwedToUser]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DebtID, 
        CreditorID, 
        DebtorID, 
        Amount, 
        Title, 
        Status, 
        CreatedAt, 
        DueDate
    FROM [Planning].[SharedDebts]
    WHERE CreditorID = @UserId
    ORDER BY DueDate ASC;
END
GO

-- ==========================================
-- 8. Get Debts User Owes (User is Debtor)
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_GetDebtsUserOwes]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DebtID, 
        CreditorID, 
        DebtorID, 
        Amount, 
        Title, 
        Status, 
        CreatedAt, 
        DueDate
    FROM [Planning].[SharedDebts]
    WHERE DebtorID = @UserId
    ORDER BY DueDate ASC;
END
GO

-- ==========================================
-- 9. Check if Shared Debt Exists
-- ==========================================
CREATE OR ALTER PROCEDURE [Planning].[sp_CheckSharedDebtExists]
    @DebtID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(1) 
    FROM [Planning].[SharedDebts]
    WHERE DebtID = @DebtID;
END
GO