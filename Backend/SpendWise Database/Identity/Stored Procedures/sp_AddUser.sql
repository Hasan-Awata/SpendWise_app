CREATE PROCEDURE [Identity].[sp_AddUser]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Automatically rolls back if a runtime error occurs

    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @CreatedUserId INT;
            DECLARE @Today DATE = CAST(GETDATE() AS DATE);
            DECLARE @EndOfMonth DATE = EOMONTH(GETDATE());

            -- 1. Create the user. 
            -- (Relies on a UNIQUE constraint on [Identity].Users(Username), no need for safety checks)
            INSERT INTO [Identity].Users (FirstName, LastName, Username, Password)
            VALUES (@FirstName, @LastName, @Username, @Password);
            
            SET @CreatedUserId = SCOPE_IDENTITY();

            -- 2. Insert initial wallets 
            INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance, IsSaved)
            VALUES 
                (@CreatedUserId, 1, 0, 0), -- Expenses wallet
                (@CreatedUserId, 1, 0, 1); -- Savings wallet

            -- 3. Insert Default Tags
            INSERT INTO [Config].Tags (UserID, Name)
            VALUES 
                (@CreatedUserId, 'General'),
                (@CreatedUserId, 'Groceries'),
                (@CreatedUserId, 'Bills');

            -- 4. Insert Default Budgeting plan (25/25/30/20)
            INSERT INTO [Planning].Budgets (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
            VALUES 
                (@CreatedUserId, 1, 25, @Today, @EndOfMonth, 1), -- Essentials
                (@CreatedUserId, 2, 25, @Today, @EndOfMonth, 1), -- Secondaries
                (@CreatedUserId, 3, 30, @Today, @EndOfMonth, 1), -- Luxuries
                (@CreatedUserId, 4, 20, @Today, @EndOfMonth, 1); -- Savings            
        COMMIT TRANSACTION;

        -- Return the ID for ExecuteScalar or output param usage
        SELECT @CreatedUserId;

    END TRY
    BEGIN CATCH
        -- Ensure the transaction is rolled back on error
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END