=========================================
 SPENDWISE DATABASE FULL DUMP
=========================================

-- =========================================
-- TABLES 
-- =========================================

CREATE TABLE [Banking].[Wallets] (
    [WalletID] int NOT NULL,
    [UserID] int NOT NULL,
    [CurrencyID] int NOT NULL,
    [Balance] decimal NOT NULL,
    [IsSaved] bit NOT NULL
);
GO

CREATE TABLE [Config].[Categories] (
    [CategoryID] int NOT NULL,
    [Name] nvarchar(100) NOT NULL,
    [Priority] int NOT NULL
);
GO

CREATE TABLE [Config].[Currencies] (
    [CurrencyID] int NOT NULL,
    [CurrencyName] nvarchar(50) NOT NULL,
    [CurrencyCode] char(3) NOT NULL
);
GO

CREATE TABLE [Config].[Tags] (
    [TagID] int NOT NULL,
    [UserID] int NOT NULL,
    [Name] nvarchar(100) NOT NULL
);
GO

CREATE TABLE [dbo].[sysdiagrams] (
    [name] sysname NOT NULL,
    [principal_id] int NOT NULL,
    [diagram_id] int NOT NULL,
    [version] int NULL,
    [definition] varbinary(MAX) NULL
);
GO

CREATE TABLE [Identity].[Users] (
    [UserID] int NOT NULL,
    [FirstName] nvarchar(100) NOT NULL,
    [LastName] nvarchar(100) NOT NULL,
    [Username] nvarchar(100) NOT NULL,
    [Password] nvarchar(255) NOT NULL,
    [RefreshToken] nvarchar(255) NULL,
    [RefreshTokenExpiryTime] datetime NULL
);
GO

CREATE TABLE [Ledger].[Expenses] (
    [ExpenseID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(255) NULL,
    [TagID] int NULL,
    [CategoryID] int NOT NULL,
    [WalletID] int NOT NULL,
    [Products] nvarchar(MAX) NOT NULL,
    [Amount] decimal NOT NULL,
    [Date] datetime NOT NULL
);
GO

CREATE TABLE [Ledger].[Incomes] (
    [IncomeID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(255) NOT NULL,
    [TagID] int NULL,
    [WalletID] int NOT NULL,
    [Amount] decimal NOT NULL,
    [Date] datetime NOT NULL
);
GO

CREATE TABLE [Ledger].[Transactions] (
    [TransactionID] int NOT NULL,
    [UserID] int NOT NULL,
    [WalletID] int NOT NULL,
    [CategoryID] int NULL,
    [TagID] int NULL,
    [GoalID] int NULL,
    [FixedExpenseID] int NULL,
    [DebtID] int NULL,
    [FixedIncomeID] int NULL,
    [Title] nvarchar(255) NOT NULL,
    [Amount] decimal NOT NULL,
    [TransactionDate] datetime NOT NULL,
    [TransactionType] int NOT NULL,
    [Description] nvarchar(MAX) NULL,
    [AmountInSp] decimal NOT NULL
);
GO

CREATE TABLE [Planning].[Budgets] (
    [BudgetID] int NOT NULL,
    [UserID] int NOT NULL,
    [CategoryID] int NOT NULL,
    [PercentageLimit] decimal NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    [IsActive] bit NOT NULL
);
GO

CREATE TABLE [Planning].[FixedExpenses] (
    [FixedExpenseID] int NOT NULL,
    [UserID] int NOT NULL,
    [CategoryID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Amount] decimal NOT NULL,
    [DueDate] date NOT NULL,
    [IsActive] bit NOT NULL
);
GO

CREATE TABLE [Planning].[FixedIncomes] (
    [FixedIncomeID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Amount] decimal NOT NULL,
    [IsMonthly] bit NOT NULL,
    [IsActive] bit NOT NULL,
    [Days] int NULL,
    [LastTime] datetime NULL
);
GO

CREATE TABLE [Planning].[SavingsGoals] (
    [GoalID] int NOT NULL,
    [UserID] int NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [TargetAmount] decimal NOT NULL,
    [CurrentAmount] decimal NOT NULL,
    [DeadlineDate] date NULL,
    [IsAchieved] bit NOT NULL,
    [CurrencyID] int NOT NULL
);
GO

CREATE TABLE [Planning].[SharedDebts] (
    [DebtID] int NOT NULL,
    [CreditorID] int NOT NULL,
    [DebtorID] int NOT NULL,
    [Amount] decimal NOT NULL,
    [Title] nvarchar(200) NOT NULL,
    [Status] nvarchar(50) NOT NULL,
    [CreatedAt] datetime NOT NULL,
    [DueDate] datetime NULL,
    [CreditorWalletID] int NULL,
    [DebtorWalletID] int NULL
);
GO

-- =========================================
-- STORED PROCEDURES 
-- =========================================

-- Schema: [Banking] | Procedure: [sp_AddWallet]

-- ==========================================
-- Add Wallet (Strict Currency Link)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_AddWallet]
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        -- 1. Explicitly verify the CurrencyId exists before inserting
        -- (Optional, but provides a clean error message that your new SqlExceptionHandler can catch!)
        IF NOT EXISTS (SELECT 1 FROM [Config].Currencies WHERE CurrencyID = @CurrencyId)
        BEGIN
            THROW 50001, 'The specified Currency ID does not exist.', 1; 
        END

        -- 2. Create the Wallet using the directly provided CurrencyId
        INSERT INTO [Banking].Wallets (UserID, CurrencyID, Balance, IsSaved)
        VALUES (@UserId, @CurrencyId, @Balance, @IsSaved);
        
        DECLARE @NewWalletID INT = SCOPE_IDENTITY();

        COMMIT TRAN; -- Lock Released: Operation succeeded
        
        -- Return the new WalletID to C#
        SELECT @NewWalletID;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO

-- Schema: [Banking] | Procedure: [sp_DeleteWallet]

-- ==========================================
-- 5. Delete a Wallet
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_DeleteWallet]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    DELETE FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
    
    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetUserWallets]

-- ==========================================
-- 2. Get All Wallets for a User (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetUserWallets]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        WalletID, 
        Balance, 
        UserID, 
        IsSaved,
        CurrencyID
    FROM [Banking].Wallets
    WHERE UserID = @UserId;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetUserWalletsPair]
CREATE PROCEDURE [Banking].[sp_GetUserWalletsPair]
	@WalletId INT,
	@UserId	 INT
AS
BEGIN
SET NOCOUNT ON;

    SELECT 
        w2.WalletID,
        w2.UserId,
        w2.CurrencyID,
        w2.Balance,
        w2.IsSaved
    FROM [Banking].Wallets w1
    INNER JOIN [Banking].Wallets w2 ON w1.UserId = w2.UserId AND w1.CurrencyId = w2.CurrencyId
    WHERE w1.WalletID = @WalletId;
END;
GO

-- Schema: [Banking] | Procedure: [sp_GetWalletById]

-- ==========================================
-- 1. Get Wallet By ID (Optimized)
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_GetWalletById]
    @WalletId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        WalletID, 
        Balance, 
        UserID, 
        IsSaved,
        CurrencyID
    FROM [Banking].Wallets
    WHERE WalletID = @WalletId AND UserID = @UserId;
END
GO

-- Schema: [Banking] | Procedure: [sp_GetWalletsByCurrencyId]
CREATE PROCEDURE [Banking].[sp_GetWalletsByCurrencyId]
	@UserId		INT,
	@CurrencyId INT
AS
BEGIN
	SELECT * FROM [Banking].Wallets 
	WHERE UserID = @UserID AND CurrencyID = @CurrencyID;
END
GO

-- Schema: [Banking] | Procedure: [sp_UpdateWallet]

-- ==========================================
-- Update Wallet 
-- ==========================================
CREATE   PROCEDURE [Banking].[sp_UpdateWallet]
    @WalletId INT,
    @UserId INT,
    @CurrencyId INT,
    @Balance DECIMAL(18,2),
    @IsSaved BIT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; -- Start Data Consistency Lock
        
        -- Optional: Explicitly verify the CurrencyId exists before updating.
        -- (If you have a Foreign Key constraint on Wallets.CurrencyID, the database will handle this automatically!)
        IF NOT EXISTS (SELECT 1 FROM [Config].Currencies WHERE CurrencyID = @CurrencyId)
        BEGIN
            THROW 50001, 'The specified Currency ID does not exist.', 1; 
        END

        -- Update the Wallet using the directly provided CurrencyId
        UPDATE [Banking].Wallets
        SET CurrencyID = @CurrencyId,
            Balance = @Balance,
            IsSaved = @IsSaved
        WHERE WalletID = @WalletId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRAN; -- Lock Released
        
        -- Return the number of rows affected
        SELECT @RowsAffected;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; -- Emergency Revert
        THROW;
    END CATCH
END
GO

-- Schema: [Config] | Procedure: [sp_CreateTag]
-- ==========================================
-- 1. Create Tag
-- ==========================================
CREATE   PROCEDURE [Config].[sp_CreateTag]
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate tag names for this specific user
    IF EXISTS (SELECT 1 FROM [Config].Tags WHERE UserID = @UserID AND Name = @Name)
    BEGIN
        THROW 50004, 'A tag with this name already exists for your account.', 1;
    END

    INSERT INTO [Config].Tags (UserID, Name)
    VALUES (@UserID, @Name);

    -- Return the new ID on success
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- Schema: [Config] | Procedure: [sp_DeleteTag]

-- ==========================================
-- 3. Delete Tag (Secured)
-- ==========================================
CREATE   PROCEDURE [Config].[sp_DeleteTag]
    @TagID INT,
    @UserID INT -- Added IDOR Security
AS
BEGIN
    SET NOCOUNT ON;

    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    DELETE FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Config] | Procedure: [sp_GetTag]

-- ==========================================
-- 4. Get Tag By ID
-- ==========================================
CREATE   PROCEDURE [Config].[sp_GetTag]
    @TagID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE TagID = @TagID AND UserID = @UserID;
END
GO

-- Schema: [Config] | Procedure: [sp_GetTags]

-- ==========================================
-- 5. Get All Tags By User
-- ==========================================
CREATE   PROCEDURE [Config].[sp_GetTags]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TagID, UserID, Name
    FROM [Config].Tags
    WHERE UserID = @UserID;
END
GO

-- Schema: [Config] | Procedure: [sp_UpdateTag]

-- ==========================================
-- 2. Update Tag (Secured)
-- ==========================================
CREATE   PROCEDURE [Config].[sp_UpdateTag]
    @TagID INT,
    @UserID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- STRICT IDOR CHECKS
    DECLARE @ActualOwnerId INT;
    SELECT @ActualOwnerId = UserID FROM [Config].Tags WHERE TagID = @TagID;

    IF @ActualOwnerId IS NULL 
        THROW 50002, 'Tag not found.', 1;

    IF @ActualOwnerId <> @UserID 
        THROW 50003, 'Access denied. You do not own this tag.', 1;

    UPDATE [Config].Tags
    SET Name = @Name
    WHERE TagID = @TagID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [dbo] | Procedure: [sp_alterdiagram]

	CREATE PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_creatediagram]

	CREATE PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_dropdiagram]

	CREATE PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_GetWalletsByCurrencyId]
CREATE PROCEDURE [dbo].[sp_GetWalletsByCurrencyId]
	@UserId		INT,
	@CurrencyId INT
AS
BEGIN
	SELECT * FROM [Banking].Wallets 
	WHERE UserID = @UserID AND CurrencyID = @CurrencyID;
END
GO

-- Schema: [dbo] | Procedure: [sp_helpdiagramdefinition]

	CREATE PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_helpdiagrams]

	CREATE PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_renamediagram]

	CREATE PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
	
GO

-- Schema: [dbo] | Procedure: [sp_UpdateUserRefreshToken]
CREATE PROCEDURE [dbo].[sp_UpdateUserRefreshToken]
	@RefreshToken NVARCHAR (255) = NULL,
	@RefreshTokenExpiryTime DATETIME = NULL,
    @UserId INT
AS
BEGIN
    UPDATE [Identity].[Users]
    SET RefreshToken = @RefreshToken,
        RefreshTokenExpiryTime = @RefreshTokenExpiryTime
    WHERE UserID = @UserId;
END
GO

-- Schema: [dbo] | Procedure: [sp_upgraddiagrams]

	CREATE PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
	
GO

-- Schema: [Identity] | Procedure: [sp_AddUser]
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
GO

-- Schema: [Identity] | Procedure: [sp_CheckUsernameExists]

-- ==========================================
-- 4. Check if Username Exists (Optimized)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_CheckUsernameExists]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Returns a simple boolean (1 or 0) for C# to read via ExecuteScalarAsync
    IF EXISTS (SELECT 1 FROM [Identity].Users WHERE Username = @Username)
        SELECT CAST(1 AS BIT);
    ELSE
        SELECT CAST(0 AS BIT);
END
GO

-- Schema: [Identity] | Procedure: [sp_GetUserById]

-- ==========================================
-- 3. Get User By ID (For Session Management)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password, RefreshToken, RefreshTokenExpiryTime
    FROM [Identity].Users
    WHERE UserID = @UserId;
END
GO

-- Schema: [Identity] | Procedure: [sp_GetUserByUsername]

-- ==========================================
-- 2. Get User By Username (For Login)
-- ==========================================
CREATE   PROCEDURE [Identity].[sp_GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT UserID, FirstName, LastName, Username, Password, RefreshToken, RefreshTokenExpiryTime
    FROM [Identity].Users
    WHERE Username = @Username;
END
GO

-- Schema: [Identity] | Procedure: [sp_UpdateUserRefreshToken]
CREATE PROCEDURE [Identity].[sp_UpdateUserRefreshToken]
	@RefreshToken NVARCHAR (255) = NULL,
	@RefreshTokenExpiryTime DATETIME = NULL,
    @UserId INT
AS
BEGIN
    UPDATE [Identity].[Users]
    SET RefreshToken = @RefreshToken,
        RefreshTokenExpiryTime = @RefreshTokenExpiryTime
    WHERE UserID = @UserId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddExpenseUsingBothWallets]
-- ====================================================================
-- Add Expense, Transaction, and Deduct Balance across multiple wallets
-- ====================================================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseUsingBothWallets]
    -- Shared PARAMETERS
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @SavingWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, 
    @AmountInSp DECIMAL(18,2), 
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewExpenseID INT OUTPUT,
    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0; 

    BEGIN TRY
        BEGIN TRAN; 

        -- 1. UPDATE WALLETS FIRST (Strictly ordered by WalletID to prevent deadlocks)
        
        DECLARE @UpdatedRows INT = 0;

        IF @PrimaryWalletId < @SavingWalletId
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromSavingWallet WHERE WalletID = @SavingWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
            
            UPDATE [Banking].Wallets SET Balance = Balance - @AmountFromPrimaryWallet WHERE WalletID = @PrimaryWalletId AND UserID = @UserId;
            SET @UpdatedRows += @@ROWCOUNT;
        END

        -- If both wallets weren't updated, either they don't exist or the user doesn't own them
        IF @UpdatedRows < 2
        BEGIN
            ;THROW 50001, 'Wallet validation failed. Check ownership or existence.', 1;
        END

        -- 2. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@UserId, @PrimaryWalletId, @CategoryId, @TagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @Title, @Amount, @AmountInSp, @Date, @TransactionType, @Description);

        SET @NewExpenseID = SCOPE_IDENTITY();
        
        -- 3. Insert Expense
        INSERT INTO [Ledger].Expenses (ExpenseID ,UserID, Title, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@NewExpenseID, @UserId, @Title, @PrimaryWalletId, @TagId, @CategoryId, @Products, @Amount, @Date);

        -- 4. COMMIT TRANSACTION ASAP
        COMMIT TRAN; 

        -- 5. POST-TRANSACTION BUDGET CHECK
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddExpenseWithTransaction]
-- ==========================================
-- 3. Add Expense, Transaction, and Deduct Balance
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_AddExpenseWithTransaction]
   -- Shared PARAMETERS
    @UserId INT,
    @WalletId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, 
    @AmountInSp DECIMAL(18,2), 
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewExpenseID INT OUTPUT,
    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0; 

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Insert Transaction
        INSERT INTO [Ledger].Transactions (UserID, WalletID, CategoryID, TagID, GoalID, FixedExpenseID, FixedIncomeID, DebtID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
        VALUES (@UserId, @WalletId, @CategoryId, @TagId, @GoalId, @FixedExpenseId, @FixedIncomeId, @DebtId, @Title, @Amount, @AmountInSp, @Date, @TransactionType, @Description);

        SET @NewExpenseID = SCOPE_IDENTITY();
        
        -- 2. Insert Expense
        INSERT INTO [Ledger].Expenses (ExpenseID ,UserID, Title, WalletID, TagID, CategoryID, Products, Amount, [Date])
        VALUES (@NewExpenseID, @UserId, @Title, @WalletId, @TagId, @CategoryId, @Products, @Amount, @Date);
        


        -- 3. UPDATE WALLET BALANCE (DEDUCT FOR EXPENSE)
        UPDATE [Banking].Wallets
        SET Balance = Balance - @Amount
        WHERE WalletID = @WalletId AND UserID = @UserId;

        -- 4. CALCULATE BUDGET STATUS USING CENTRALIZED FUNCTION
        -- The function is called before COMMIT so it includes the transaction just inserted.
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        COMMIT TRAN; 

        -- Return values for the application layer
        SELECT @NewExpenseID AS NewExpenseID, @IsOverLimit AS IsOverLimit;

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_AddIncomeWithTransaction]
CREATE PROCEDURE [Ledger].[sp_AddIncomeWithTransaction]
    -- Shared Parameters
    @UserId INT,
    @WalletId INT,
    @Amount DECIMAL(18,2),
    @IncomeDate DATETIME,
    @Title NVARCHAR(255),
    @TagId INT = NULL,

    -- Transaction Only PARAMETERS
    @Description NVARCHAR(MAX) = NULL,
    @AmountInSp DECIMAL(18,2) = 0,
    @TransactionType INT = 0, 
    @GoalId INT = NULL,
    @DebtId INT = NULL,
    @FixedIncomeId INT = NULL,
    @FixedExpenseId INT = NULL,

    -- OUTPUT PARAMETERS
    @NewIncomeID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS 
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END

        BEGIN TRAN; 

        -- 2. INSERT INTO TRANSACTIONS FIRST
        -- This generates the Identity ID that the Income will inherit
        INSERT INTO [Ledger].[Transactions] (
            UserID, WalletID, TagID, Title, Amount, 
            AmountInSp, TransactionDate, TransactionType, 
            [Description], GoalID, DebtID, FixedIncomeID, FixedExpenseID
        )
        VALUES (
            @UserId, @WalletId, @TagId, @Title, @Amount, 
            @AmountInSp, @IncomeDate, @TransactionType, 
            @Description, @GoalId, @DebtId, @FixedIncomeId, @FixedExpenseId
        );
        
        -- Capture the ID generated by the Transactions table
        SET @NewIncomeID = SCOPE_IDENTITY();

        -- 3. INSERT INTO INCOMES SECOND
        -- Note: IncomeID is NOT an identity; we force it to match @NewIncomeID
        INSERT INTO [Ledger].[Incomes] (
            IncomeID, UserID, WalletID, TagID, 
            Title, Amount, [Date]
        )
        VALUES (
            @NewIncomeID, @UserId, @WalletId, @TagId, 
            @Title, @Amount, @IncomeDate
        );

        -- 4. UPDATE WALLET BALANCE (ADD FOR INCOME)
        UPDATE [Banking].[Wallets]
        SET Balance = Balance + @Amount
        WHERE WalletID = @WalletId AND UserID = @UserId;

        COMMIT TRAN; 

        -- Return the ID to the application
        SELECT @NewIncomeID AS NewIncomeID;

    END TRY
    BEGIN CATCH
        -- Ensure the entire operation is rolled back if ANY step fails
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW; 
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_DeleteExpense]

-- ==========================================
-- 5. Delete Expense, Transaction, and Refund Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_DeleteExpense]
    @ExpenseId INT,
    @UserId INT -- Added for IDOR Security
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- STRICT SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @ActualOwnerId = UserID, @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END

        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 
        
        -- 1. Delete dependencies safely
        DELETE FROM [Ledger].Transactions WHERE TransactionID = @ExpenseId AND UserID = @UserId;
        -- DELETE FROM [Ledger].Expenses WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 2. Refund the money to the wallet since the expense was deleted
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Banking].Wallets 
            SET Balance = Balance + @AmountToRevert 
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_DeleteIncome]

-- ==========================================
-- 5. Delete Income, Transaction, and Revert Balance 
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_DeleteIncome]
    @IncomeId INT,
    @UserId INT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN; 
        
        -- 1. Capture the amount and wallet to revert (Ensuring ownership)
        DECLARE @AmountToRevert DECIMAL(18,2);
        DECLARE @WalletId INT;
        
        SELECT @AmountToRevert = Amount, @WalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @UserId; 

        IF @AmountToRevert IS NULL 
            THROW 50002, 'Income record was not found or access is denied.', 1;

        -- 2. Delete dependencies safely
        -- REMINDER: TransactionID == IncomeID
        DELETE FROM [Ledger].Transactions WHERE TransactionID = @IncomeId AND UserID = @UserId;
       -- DELETE FROM [Ledger].Incomes WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- 3. Subtract the money from the wallet since the income was deleted
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Banking].Wallets 
            SET Balance = Balance - @AmountToRevert 
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 
        SELECT @RowsAffected;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetExpense]
CREATE PROCEDURE [Ledger].[sp_GetExpense]
    @ExpenseId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseID, 
        e.UserID,
        e.Title,
        e.Amount, 
        e.Products, 
        e.[Date], 
        e.WalletID, 
        e.CategoryID, 
        e.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Expenses] e
    INNER JOIN [Ledger].[Transactions] t ON e.ExpenseID = t.TransactionID
    WHERE ExpenseID = @ExpenseId AND e.UserID = @UserId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetExpensesByUserPaged]

-- ==========================================
-- 2. Get Expenses By User Paged (Optimized: No Joins!)
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetExpensesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Expenses
    WHERE UserID = @UserId;

    SELECT 
        e.ExpenseID, 
        e.UserID,
        e.Title,
        e.Amount, 
        e.Products, 
        e.[Date], 
        e.WalletID, 
        e.CategoryID, 
        e.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Expenses] e
    INNER JOIN [Ledger].[Transactions] t ON e.ExpenseID = t.TransactionID
    WHERE e.UserID = @UserId
    ORDER BY Date DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetIncome]
-- ==========================================
-- 1. Get Income By ID 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncome]
    @IncomeID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        i.IncomeID, 
        i.UserID,
        i.Title,
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].[Incomes] i
    INNER JOIN [Ledger].[Transactions] t ON i.IncomeID = t.TransactionID
    WHERE i.IncomeID = @IncomeID AND i.UserID = @UserID;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetIncomesByUserPaged]
-- ==========================================
-- 2. Get Incomes By User Paged (With Description)
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetIncomesByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

    -- Result Set 2: Paged Incomes with Transaction Details
    SELECT 
        i.IncomeID, 
        i.UserID, 
        i.Title, 
        i.Amount, 
        i.[Date], 
        i.WalletID, 
        i.TagID,
        t.[Description],
        t.[AmountInSp]
    FROM [Ledger].Incomes i
    INNER JOIN [Ledger].Transactions t ON i.IncomeID = t.TransactionID
    WHERE i.UserID = @UserId
    ORDER BY i.[Date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetProducts]

-- ==========================================
-- 6. Get Products JSON String
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_GetProducts]
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Products 
    FROM [Ledger].[Expenses] 
    WHERE ExpenseID = @ExpenseId;
END
GO

-- Schema: [Ledger] | Procedure: [sp_GetTransactionsByUserPaged]
-- ==========================================
-- Get Transactions By User Paged 
-- ==========================================
CREATE PROCEDURE [Ledger].[sp_GetTransactionsByUserPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Count
    SELECT COUNT(*) AS TotalCount
    FROM [Ledger].Incomes
    WHERE UserID = @UserId;

    -- Result Set 2: Paged Transactions with Transaction Details
    SELECT 
        TransactionID,
        UserID,
        Title,
        Description,
        Amount,
        AmountInSp,
        TransactionDate,
        TransactionType,
        WalletID,
        CategoryID,
        TagID,
        GoalID,
        FixedExpenseID,
        FixedIncomeID,
        DebtID
        
    FROM [Ledger].Transactions
    WHERE UserID = @UserId
    ORDER BY [TransactionDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateExpenseUsingBothWallets]
CREATE PROCEDURE [Ledger].[sp_UpdateExpenseUsingBothWallets]
    @ExpenseId INT,
    @UserId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @PrimaryWalletId INT,
    @AmountFromPrimaryWallet DECIMAL(18,2),
    @AmountFromSavingWallet DECIMAL(18,2),

    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1,
    @AmountInSp DECIMAL(18,2),
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IsOverLimit = 0;

    BEGIN TRY
        -- ==========================================
        -- 1. STATE FETCH (Fetch historical state)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldPrimaryWalletId INT;
        
        SELECT 
            @ActualOwnerId = UserID, 
            @OldAmount = Amount, 
            @OldPrimaryWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        -- DYNAMIC LOOKUP: Find the new saving wallet paired with the new primary wallet
        DECLARE @NewSavingWalletId INT;
        SELECT @NewSavingWalletId = W2.WalletID
        FROM [Banking].Wallets W1
        JOIN [Banking].Wallets W2 ON W1.CurrencyID = W2.CurrencyID 
            AND W2.IsSaved = 1
            AND W2.UserID = @UserId
        WHERE W1.WalletID = @PrimaryWalletId;

        -- ==========================================
        -- 2. TRANSACTION EXECUTION
        -- ==========================================
        BEGIN TRAN; 

        -- Update Expense Table
        UPDATE [Ledger].Expenses
        SET WalletID = @PrimaryWalletId, 
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date,
            Title = @Title
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        IF @RowsAffected > 0
        BEGIN
            -- Update Transaction Table
            UPDATE [Ledger].Transactions
            SET WalletID = @PrimaryWalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description,
                GoalID = @GoalId,
                FixedExpenseID = @FixedExpenseId,
                FixedIncomeID = @FixedIncomeId,
                DebtID = @DebtId
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- =========================================================
            -- 3. NET BALANCE MATH (Your Reversal Logic + New Deductions)
            -- =========================================================
            DECLARE @WalletAdjustments TABLE (
                WalletID INT,
                Modifier DECIMAL(18,2)
            );

            -- Step A: Full Refund to the Old Primary Wallet
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES (@OldPrimaryWalletId, @OldAmount);

            -- Step B: Apply New Deductions to New Wallets
            INSERT INTO @WalletAdjustments (WalletID, Modifier)
            VALUES 
            (@PrimaryWalletId, -@AmountFromPrimaryWallet),
            (@NewSavingWalletId, -@AmountFromSavingWallet);

            -- Process physical database updates grouped and in strict WalletID order.
            -- This cleanly handles cases where @OldPrimaryWalletId and @PrimaryWalletId 
            -- are the exact same row by combining them into one single atomic update.
            DECLARE @CurrentWalletID INT;
            DECLARE @CurrentModifier DECIMAL(18,2);

            DECLARE WalletCursor CURSOR LOCAL FAST_FORWARD FOR
                SELECT WalletID, SUM(Modifier) 
                FROM @WalletAdjustments 
                WHERE WalletID IS NOT NULL
                GROUP BY WalletID
                HAVING SUM(Modifier) <> 0 -- Skip if the net change is perfectly zero
                ORDER BY WalletID ASC;    -- Anti-deadlock sorting

            OPEN WalletCursor;
            FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @CurrentModifier
                WHERE WalletID = @CurrentWalletID AND UserID = @UserId;

                FETCH NEXT FROM WalletCursor INTO @CurrentWalletID, @CurrentModifier;
            END

            CLOSE WalletCursor;
            DEALLOCATE WalletCursor;
        END

        COMMIT TRAN; 

        -- 4. POST-TRANSACTION BUDGET EVALUATION
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateExpenseWithTransaction]

-- ==========================================
-- 4. Update Expense, Transaction, and Adjust Balance
-- ==========================================
CREATE   PROCEDURE [Ledger].[sp_UpdateExpenseWithTransaction]
    @ExpenseId INT,
    @UserId INT,
    @WalletId INT,
    @CategoryId INT,
    @Products NVARCHAR(MAX) = NULL, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @Date DATETIME,
    @Title NVARCHAR(255),
    
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1,
    @AmountInSp DECIMAL(18,2),
    @GoalId INT = NULL,
    @FixedExpenseId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL,

    @IsOverLimit BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS (IDOR)
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- EXPENSE SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        SELECT @ActualOwnerId = UserID, @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Expenses 
        WHERE ExpenseID = @ExpenseId;

        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'Expense record was not found.', 1;
        END
        
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this expense record.', 1;
        END

        BEGIN TRAN; 

        -- 1. Update Expense
        UPDATE [Ledger].Expenses
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            Products = @Products,
            Amount = @Amount,
            Date = @Date
        WHERE ExpenseID = @ExpenseId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- Update Transaction and Wallets (Only if expense exists)
        IF @RowsAffected > 0
        BEGIN
            UPDATE [Ledger].Transactions
            SET WalletID = @WalletId,
                CategoryID = @CategoryId,
                TagID = @TagId,
                Title = @Title,
                Amount = @Amount,
                AmountInSp = @AmountInSp, 
                TransactionDate = @Date,
                TransactionType = @TransactionType,
                Description = @Description
            WHERE TransactionID = @ExpenseId AND UserID = @UserId;

            -- Balance Math logic 
            IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance + @OldAmount - @Amount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            ELSE
            BEGIN
                UPDATE [Banking].Wallets SET Balance = Balance + @OldAmount WHERE WalletID = @OldWalletId AND UserID = @UserId;
                UPDATE [Banking].Wallets SET Balance = Balance - @Amount WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        -- Update the output variable using the function
        SET @IsOverLimit = [Planning].[fn_IsOverCategoryBudget](@UserId, @CategoryId, @Date);

        COMMIT TRAN; 

        -- Return as result set for the Reader
        SELECT @RowsAffected AS RowsAffected, @IsOverLimit AS IsOverLimit;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Ledger] | Procedure: [sp_UpdateIncomeWithTransaction]
CREATE PROCEDURE [Ledger].[sp_UpdateIncomeWithTransaction]
    @IncomeId INT, -- This is also the TransactionID
    @UserId INT,
    @WalletId INT, 
    @TagId INT = NULL,
    @Amount DECIMAL(18,2),
    @IncomeDate DATETIME,
    
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 0,
    @AmountInSp DECIMAL(18,2), 
    @CategoryId INT = NULL,
    @GoalId INT = NULL,
    @FixedIncomeId INT = NULL,
    @DebtId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY CHECKS 
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].Wallets WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
        END


        BEGIN TRAN; 

        -- 2. FETCH OLD DATA FOR RE-BALANCING
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        -- fetch the old values
        SELECT @OldAmount = Amount, @OldWalletId = WalletID 
        FROM [Ledger].Incomes 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;

        IF @OldAmount IS NULL 
            THROW 50002, 'Income record was not found.', 1;

        -- 3. UPDATE THE INCOME TABLE
        UPDATE [Ledger].Incomes
        SET WalletID = @WalletId,
            TagID = @TagId,
            Amount = @Amount,
            [Date] = @IncomeDate,
            Title = @Title 
        WHERE IncomeID = @IncomeId AND UserID = @UserId;
        
        -- 4. UPDATE THE TRANSACTION TABLE
        -- Note: We use TransactionID = @IncomeId
        UPDATE [Ledger].Transactions
        SET WalletID = @WalletId,
            CategoryID = @CategoryId,
            TagID = @TagId,
            GoalID = @GoalId,
            FixedIncomeID = @FixedIncomeId,
            DebtID = @DebtId,
            Title = @Title,
            Amount = @Amount,
            AmountInSp = @AmountInSp, 
            TransactionDate = @IncomeDate,
            TransactionType = @TransactionType,
            [Description] = @Description
        WHERE TransactionID = @IncomeId AND UserID = @UserId;

        -- 5. UPDATE WALLET BALANCE (THE MATH)
        -- Scenario A: Wallet stayed the same
        IF @OldWalletId = @WalletId
            BEGIN
                UPDATE [Banking].Wallets
                SET Balance = Balance - @OldAmount + @Amount -- Revert old, add new
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            -- Scenario B: Wallet changed (Move money between wallets)
            ELSE
            BEGIN
                -- Remove old amount from the old wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance - @OldAmount 
                WHERE WalletID = @OldWalletId AND UserID = @UserId;

                -- Add new amount to the new wallet
                UPDATE [Banking].Wallets 
                SET Balance = Balance + @Amount 
                WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN; 

        -- Return 1 to indicate success
        SELECT 1 AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AddCategoryBudget]
-- ==========================================
-- 1. Add Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_AddCategoryBudget]
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE UserID = @UserID AND CategoryID = @CategoryID)
        THROW 50004, 'A budget for this category already exists for the user.', 1;
   
   IF (SELECT ISNULL(SUM(PercentageLimit), 0) + @PercentageLimit FROM [Planning].[Budgets] WHERE UserID = @UserID) > 100
    THROW 50005, 'Wrong input, total categories budget percentage cannot exceed 100%.', 1;

    INSERT INTO [Planning].[Budgets] (UserID, CategoryID, PercentageLimit, StartDate, EndDate, IsActive)
    VALUES (@UserID, @CategoryID, @PercentageLimit, @StartDate, @EndDate, @IsActive);
    
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- Schema: [Planning] | Procedure: [sp_AddSavingGoalWithTransaction]
-- ==========================================
-- Add Saving Goal, Create Tracking Transaction, and Deduct Wallet Balance
-- ==========================================
CREATE PROCEDURE [Planning].[sp_AddSavingGoalWithTransaction]
    -- Saving Goal Parameters
    @UserId INT,
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE,

    -- Transaction & Wallet Parameters
    @WalletId INT,
    @CategoryId INT, -- e.g., A system category ID assigned for Savings/Investments
    @AmountInSp DECIMAL(18,2),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1, -- Defaulting to Expense type layout

    -- Output Parameter
    @NewGoalID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT SECURITY & VALIDATION CHECKS
        -- ==========================================
        
        -- 1. Core Target Validations
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- 2. Prevent duplicate goal titles for the same user
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- 3. Only run Wallet validations if money is actually being allocated right now
        IF @CurrentAmount > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId)
            BEGIN
                ;THROW 50001, 'Wallet not found.', 1;
            END

            IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
            BEGIN
                ;THROW 50003, 'Access denied. You do not own this wallet.', 1;
            END
            
            -- Optional: Check if wallet has sufficient balance before proceeding
            IF (SELECT Balance FROM [Banking].[Wallets] WHERE WalletID = @WalletId) < @CurrentAmount
            BEGIN
                ;THROW 50009, 'Insufficient wallet balance for this initial savings allocation.', 1;
            END
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN;

        -- Step 1: Insert into SavingsGoals to get the primary key ID
        INSERT INTO [Planning].[SavingsGoals] 
            (UserID, Title, TargetAmount, CurrentAmount, DeadlineDate)
        VALUES 
            (@UserId, @Title, @TargetAmount, @CurrentAmount, @DeadlineDate);
        
        SET @NewGoalID = CAST(SCOPE_IDENTITY() AS INT);

        -- Step 2: If there is an initial amount allocated, run ledger tracking changes
        IF @CurrentAmount > 0
        BEGIN
            -- Insert Audit Transaction record referencing the newly created GoalID
            INSERT INTO [Ledger].[Transactions] 
                (UserID, WalletID, CategoryID, GoalID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
            VALUES 
                (@UserId, @WalletId, @CategoryId, @NewGoalID, @Title, @CurrentAmount, @AmountInSp, GETDATE(), @TransactionType, @Description);

            -- Deduct the initial savings allocation from the originating wallet balance
            UPDATE [Banking].[Wallets]
            SET Balance = Balance - @CurrentAmount
            WHERE WalletID = @WalletId AND UserID = @UserId;
        END

        COMMIT TRAN;

        -- Return values for the application layer execution satisfaction
        SELECT @NewGoalID AS NewGoalID;

    END TRY
    BEGIN CATCH
        -- Rollback if any unexpected exception or constraint error breaks execution context
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_AddSharedDebt]
CREATE PROCEDURE [Planning].[sp_AddSharedDebt]
	@CreditorID INT,
	@DebtorID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(200),
	@Status NVARCHAR(50),
	@DueDate DATETIME = NULL,
	@CreditorWalletID INT = NULL,
	@DebtorWalletID INT = NULL
AS
BEGIN
	INSERT INTO [Planning].[SharedDebts]
		([CreditorID], [DebtorID], [Amount], [Title], [Status], [DueDate], [CreditorWalletID], [DebtorWalletID])
	VALUES
		(@CreditorID, @DebtorID, @Amount, @Title, @Status, @DueDate, @CreditorWalletID, @DebtorWalletID);
	SELECT SCOPE_IDENTITY();
END
GO

-- Schema: [Planning] | Procedure: [sp_CheckSavingGoalExists]
-- ==========================================
-- 8. Check Saving Goal Exists
-- ==========================================
CREATE PROCEDURE [Planning].[sp_CheckSavingGoalExists]
    @GoalId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE GoalID = @GoalId)
        SELECT 1;
    ELSE
        SELECT 0;
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteCategoryBudget]

-- ==========================================
-- 5. Delete Single Budget 
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_DeleteCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    DELETE FROM [Planning].Budgets 
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    -- Returns the number of rows affected to C# (ExecuteNonQueryAsync)
    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Planning] | Procedure: [sp_DeleteSharedDebt]
CREATE PROCEDURE [Planning].[sp_DeleteSharedDebt]
	@DebtID INT
AS
BEGIN
	DELETE FROM [Planning].[SharedDebts]
	WHERE [DebtID] = @DebtID AND [Status] <> 'Accepted';
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAchievedGoals]
-- ==========================================
-- 7. Get Achieved Saving Goals
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetAchievedGoals]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId 
      AND CurrentAmount >= TargetAmount
    ORDER BY DeadlineDate DESC;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAllUserBudgets]
-- ==========================================
-- 3. Get All Budgets (DYNAMIC CALCULATION)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_GetAllUserBudgets]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Aggregate all relevant transactions once
    ;WITH UserTotals AS (
        SELECT 
            CategoryID,
            SUM(CASE WHEN TransactionType = 0 THEN AmountInSp ELSE 0 END) AS TotalIncome,
            SUM(CASE WHEN TransactionType = 1 THEN AmountInSp ELSE 0 END) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID
        GROUP BY CategoryID
    ),
    -- 2. Get global income separately (since income isn't usually tied to a category)
    GlobalIncome AS (
        SELECT SUM(AmountInSp) as OverallIncome 
        FROM [Ledger].[Transactions] 
        WHERE UserID = @UserID AND TransactionType = 0
    )
    
    SELECT
        b.BudgetID,
        b.UserID,
        b.CategoryID,
        b.PercentageLimit,
        b.StartDate,
        b.EndDate,
        b.IsActive,

        -- The "Allowance" in currency (e.g., $300)
        CAST((gi.OverallIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        -- The "Actual Spent" in currency (e.g., $30)
        COALESCE(ut.TotalSpent, 0) AS SpendingProgress,
        -- The Percentage of the Budget used (e.g., 10%)
        CAST(
            CASE 
                WHEN gi.OverallIncome > 0 AND b.PercentageLimit > 0 
                THEN (COALESCE(ut.TotalSpent, 0) / (gi.OverallIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0 
            END AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS JOIN GlobalIncome gi
    LEFT JOIN UserTotals ut ON b.CategoryID = ut.CategoryID
    WHERE b.UserID = @UserID;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetAllUserGoalsPaged]
-- ==========================================
-- 6. Get All User Saving Goals (Paged)
-- ==========================================
CREATE PROCEDURE [Planning].[sp_GetAllUserGoalsPaged]
    @UserId INT,
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;

    -- First Result Set: Total Count of goals for this user
    SELECT COUNT(*) AS TotalCount
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId;

    -- Second Result Set: The actual paged goals data
    SELECT 
        GoalID, 
        UserID, 
        Title, 
        TargetAmount, 
        CurrentAmount, 
        DeadlineDate, 
        CurrencyID
    FROM [Planning].[SavingsGoals]
    WHERE UserID = @UserId
    ORDER BY GoalID DESC  -- Displays the newest goals first
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetCategoryBudget]
CREATE PROCEDURE [Planning].[sp_GetCategoryBudget]
    @CategoryID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.BudgetID, 
        b.UserID, 
        b.CategoryID, 
        b.PercentageLimit, 
        b.StartDate, 
        b.EndDate, 
        b.IsActive,
        CAST((Totals.TotalIncome * (b.PercentageLimit / 100.0)) AS DECIMAL(18,2)) AS MoneyLimit,
        
        Totals.TotalSpent AS SpendingProgress,
        
        CAST(
            CASE
                WHEN Totals.TotalIncome > 0 AND b.PercentageLimit > 0 
                THEN (Totals.TotalSpent / (Totals.TotalIncome * (b.PercentageLimit / 100.0))) * 100.0
                ELSE 0.0
            END 
        AS DECIMAL(18,2)) AS PercentageProgress
    FROM [Planning].[Budgets] b
    CROSS APPLY (
        SELECT
            -- Global income for the user within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 0 THEN AmountInSp END), 0) AS TotalIncome,
            -- Specific spending for ONLY this category within the budget's date range
            COALESCE(SUM(CASE WHEN TransactionType = 1 AND CategoryID = @CategoryID THEN AmountInSp END), 0) AS TotalSpent
        FROM [Ledger].[Transactions]
        WHERE UserID = @UserID 
          AND TransactionDate BETWEEN b.StartDate AND b.EndDate
    ) AS Totals
    WHERE b.CategoryID = @CategoryID AND b.UserID = @UserID;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtById]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtById]
	@DebtID INT
AS
BEGIN
	SELECT * FROM [Planning].[SharedDebts] WHERE [DebtID] = @DebtID;
END
GO

-- Schema: [Planning] | Procedure: [sp_GetSharedDebtsForUser]
CREATE PROCEDURE [Planning].[sp_GetSharedDebtsForUser]
	@UserID INT
AS
BEGIN
	SELECT * FROM [Planning].[SharedDebts]
	WHERE [CreditorID] = @UserID OR [DebtorID] = @UserID;
END
GO

-- Schema: [Planning] | Procedure: [sp_ReturnDebtAmount]
CREATE PROCEDURE [Planning].[sp_ReturnDebtAmount]
	@DebtID INT,
	@Amount DECIMAL(18,2),
	@Title NVARCHAR(255),
	@Description NVARCHAR(MAX) = NULL,
	@AmountInSp DECIMAL(18,2)
AS
BEGIN
	DECLARE @CreditorID INT, @CreditorWalletID INT, @DebtorID INT, @DebtorWalletID INT;
	SELECT @CreditorID = CreditorID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @DebtorID = DebtorID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @CreditorWalletID = CreditorWalletID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	SELECT @DebtorWalletID = DebtorWalletID FROM Planning.SharedDebts WHERE @DebtID = DebtID;
	
	BEGIN TRAN
		INSERT INTO [Ledger].[Transactions]
			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES
			(@CreditorID, @CreditorWalletID, @DebtID, @Title, @Amount, 1, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance + @Amount
		WHERE @CreditorWalletID = WalletID;

		INSERT INTO [Ledger].[Transactions]
			([UserID], [WalletID], [DebtID], [Title], [Amount], [TransactionType], [Description],[AmountInSp])
		VALUES
			(@DebtorID, @DebtorWalletID, @DebtID, @Title, @Amount, 0, @Description, @AmountInSp);
		UPDATE Banking.Wallets
		SET Balance = Balance - @Amount
		WHERE @DebtorWalletID = WalletID;
	COMMIT TRAN;

	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateCategoryBudget]
-- ==========================================
-- 2. Update Category Budget (Updated)
-- ==========================================
CREATE   PROCEDURE [Planning].[sp_UpdateCategoryBudget]
    @BudgetID INT,
    @UserID INT,
    @CategoryID INT,
    @PercentageLimit DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [Planning].[Budgets] WHERE CategoryID = @CategoryID AND UserID = @UserID)
        THROW 50003, 'Access denied. You do not own this budget.', 1;

    UPDATE [Planning].[Budgets]
    SET PercentageLimit = @PercentageLimit,
        StartDate = @StartDate,
        EndDate = @EndDate,
        IsActive = @IsActive
    WHERE CategoryID = @CategoryID AND UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateSavingGoal]
-- ==========================================
-- 3. Update Saving Goal, Sync Transactions, and Adjust Wallet Balances
-- ==========================================
CREATE PROCEDURE [Planning].[sp_UpdateSavingGoal]
    -- Saving Goal Parameters
    @GoalId INT,
    @UserId INT, -- Kept for strict IDOR Security verification
    @Title NVARCHAR(100),
    @TargetAmount DECIMAL(18,2),
    @CurrentAmount DECIMAL(18,2),
    @DeadlineDate DATE,

    -- Transaction & Wallet Sync Parameters
    @WalletId INT,
    @CategoryId INT,
    @AmountInSp DECIMAL(18,2),
    @Description NVARCHAR(MAX) = NULL,
    @TransactionType INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- ==========================================
        -- PRE-FLIGHT WALLET SECURITY CHECKS (IDOR)
        -- ==========================================
        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId)
        BEGIN
            ;THROW 50001, 'Target wallet not found.', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM [Banking].[Wallets] WHERE WalletID = @WalletId AND UserID = @UserId)
        BEGIN
            ;THROW 50003, 'Access denied. You do not own the target wallet.', 1;
        END

        -- ==========================================
        -- SAVING GOAL SECURITY CHECKS (IDOR)
        -- ==========================================
        DECLARE @ActualOwnerId INT;
        DECLARE @OldCurrentAmount DECIMAL(18,2);
        DECLARE @OldWalletId INT;
        
        -- Retrieve the existing state of the saving goal
        SELECT 
            @ActualOwnerId = UserID, 
            @OldCurrentAmount = CurrentAmount
        FROM [Planning].[SavingsGoals] 
        WHERE GoalID = @GoalId;

        -- 1. Verify existence
        IF @ActualOwnerId IS NULL 
        BEGIN
            ;THROW 50002, 'The specified saving goal was not found.', 1;
        END
        
        -- 2. Verify authorization
        IF @ActualOwnerId <> @UserId
        BEGIN
            ;THROW 50003, 'Access denied. You do not own this saving goal.', 1;
        END

        -- Fetch the old wallet ID historically linked to this savings progress transaction
        SELECT TOP 1 @OldWalletId = WalletID
        FROM [Ledger].[Transactions]
        WHERE GoalID = @GoalId AND UserID = @UserId
        ORDER BY TransactionDate DESC;

        -- Fallback if an initial transaction was never logged for this goal
        IF @OldWalletId IS NULL SET @OldWalletId = @WalletId;

        -- ==========================================
        -- CORE BUSINESS VALUE VALIDATIONS
        -- ==========================================
        IF @TargetAmount <= 0
        BEGIN
            ;THROW 50007, 'The target amount must be greater than zero.', 1;
        END

        IF @CurrentAmount < 0
        BEGIN
            ;THROW 50008, 'The current amount cannot be negative.', 1;
        END

        -- Prevent duplicate titles across different goals for the same user
        IF EXISTS (SELECT 1 FROM [Planning].[SavingsGoals] WHERE UserID = @UserId AND Title = @Title AND GoalID <> @GoalId)
        BEGIN
            ;THROW 50006, 'A saving goal with this title already exists for the user.', 1;
        END

        -- ==========================================
        -- TRANSACTION PROCESSING
        -- ==========================================
        BEGIN TRAN; 

        -- Step 1. Update core Saving Goal values
        UPDATE [Planning].[SavingsGoals]
        SET Title = @Title,
            TargetAmount = @TargetAmount,
            CurrentAmount = @CurrentAmount,
            DeadlineDate = @DeadlineDate
        WHERE GoalID = @GoalId AND UserID = @UserId;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;

        -- Step 2. Sync underlying Ledger logs and swap wallet balances if goal exists
        IF @RowsAffected > 0
        BEGIN
            -- If a ledger entry exists, update it. If not, generate an entry for the fresh deposit funds.
            IF EXISTS (SELECT 1 FROM [Ledger].[Transactions] WHERE GoalID = @GoalId AND UserID = @UserId)
            BEGIN
                UPDATE [Ledger].[Transactions]
                SET WalletID = @WalletId,
                    CategoryID = @CategoryId,
                    Title = @Title,
                    Amount = @CurrentAmount,
                    AmountInSp = @AmountInSp, 
                    TransactionDate = GETDATE(),
                    TransactionType = @TransactionType,
                    Description = @Description
                WHERE GoalID = @GoalId AND UserID = @UserId;
            END
            ELSE IF @CurrentAmount > 0
            BEGIN
                INSERT INTO [Ledger].[Transactions]
                    (UserID, WalletID, CategoryID, GoalID, Title, Amount, AmountInSp, TransactionDate, TransactionType, Description)
                VALUES
                    (@UserId, @WalletId, @CategoryId, @GoalId, @Title, @CurrentAmount, @AmountInSp, GETDATE(), @TransactionType, @Description);
            END

            -- Step 3. Balance Reversion Math Logic (Deducting/refunding capital differences)
            IF @OldWalletId = @WalletId
            BEGIN
                -- Money allocated to savings acts like an expense. 
                -- If new savings amount is larger, deduct more from wallet. If lower, refund back to wallet.
                UPDATE [Banking].[Wallets]
                SET Balance = Balance + @OldCurrentAmount - @CurrentAmount
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
            ELSE
            BEGIN
                -- Wallet has swapped. Refund old wallet completely, then charge the new wallet.
                UPDATE [Banking].[Wallets] 
                SET Balance = Balance + @OldCurrentAmount 
                WHERE WalletID = @OldWalletId AND UserID = @UserId;

                UPDATE [Banking].[Wallets] 
                SET Balance = Balance - @CurrentAmount 
                WHERE WalletID = @WalletId AND UserID = @UserId;
            END
        END

        COMMIT TRAN; 

        -- Return execution details to satisfy ExecuteScalarAsync / Reader context
        SELECT @RowsAffected AS RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN; 
        THROW;
    END CATCH
END
GO

-- Schema: [Planning] | Procedure: [sp_UpdateSharedDebt]
CREATE PROCEDURE [Planning].[sp_UpdateSharedDebt]
	@DebtID INT,
	@UserID INT,
	@Amount DECIMAL(18,2) = NULL,
	@Title NVARCHAR(200) = NULL,
	@DueDate DATETIME = NULL,
	@Status NVARCHAR(50) = NULL
AS
BEGIN
	-- Only creditor can update amount, title, duedate
	UPDATE [Planning].[SharedDebts]
	SET
		[Amount] = CASE WHEN [CreditorID] = @UserID AND @Amount IS NOT NULL THEN @Amount ELSE [Amount] END,
		[Title] = CASE WHEN [CreditorID] = @UserID AND @Title IS NOT NULL THEN @Title ELSE [Title] END,
		[DueDate] = CASE WHEN [CreditorID] = @UserID AND @DueDate IS NOT NULL THEN @DueDate ELSE [DueDate] END,
		[Status] = CASE WHEN @Status IS NOT NULL THEN @Status ELSE [Status] END
	WHERE [DebtID] = @DebtID;
END
GO

