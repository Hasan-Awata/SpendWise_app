-- 1. Check that ActualValue on Currency is more than 0
ALTER TABLE Config.Currencies
ADD CONSTRAINT CHK_Currencies_ActualValue CHECK (ActualValue > 0);

-- 2. Check that the Wallet is unique on UserID, CurrencyID, and IsSaved
ALTER TABLE Banking.Wallets
ADD CONSTRAINT UQ_Wallets_UserCurrencySaved UNIQUE (UserID, CurrencyID, IsSaved);

-- 3. Check the Tag is unique on UserID and TagName
ALTER TABLE Config.Tags
ADD CONSTRAINT UQ_Tags_UserTagName UNIQUE (UserID, Name);

-- 4. Check the Goal is unique on UserID, Title, and IsAchieved
ALTER TABLE Planning.SavingsGoals
ADD CONSTRAINT UQ_SavingsGoals_UserTitleAchieved UNIQUE (UserID, Title, IsAchieved);

-- 5. Check the Budget is unique on UserID, CategoryID, and IsActive
ALTER TABLE Planning.Budgets
ADD CONSTRAINT UQ_Budgets_UserCategoryActive UNIQUE (UserID, CategoryID, IsActive);

-- 6. Check the User is unique on Username
ALTER TABLE [Identity].[Users]
ADD CONSTRAINT UQ_Users_Username UNIQUE (Username);

-- 7. Check the Amount on all tables is more than 0
-- (Applying this to all tables from your ERD that typically handle transaction amounts)
ALTER TABLE Ledger.Transactions
ADD CONSTRAINT CHK_Transactions_Amount CHECK (Amount > 0);

ALTER TABLE Ledger.Incomes
ADD CONSTRAINT CHK_Incomes_Amount CHECK (Amount > 0);

ALTER TABLE Ledger.Expenses
ADD CONSTRAINT CHK_Expenses_Amount CHECK (Amount > 0);

ALTER TABLE Planning.FixedIncomes
ADD CONSTRAINT CHK_FixedIncomes_Amount CHECK (Amount > 0);

ALTER TABLE Planning.FixedExpenses
ADD CONSTRAINT CHK_FixedExpenses_Amount CHECK (Amount > 0);

-- 8. Check the unique on Fixed Income on UserID, TagID, Title, and IsActive
ALTER TABLE Planning.FixedIncomes ADD TagID INT NOT NULL;
ALTER TABLE Planning.FixedIncomes
ADD CONSTRAINT FK_FixedIncomes_Tags FOREIGN KEY (TagID) REFERENCES Config.Tags(TagID);

ALTER TABLE Planning.FixedIncomes
ADD CONSTRAINT UQ_FixedIncomes_UserTagTitleActive UNIQUE (UserID, TagID, Title, IsActive);

-- 9. Check the unique on Fixed Expense on UserID, Title, and IsActive
ALTER TABLE Planning.FixedExpenses
ADD CONSTRAINT UQ_FixedExpenses_UserTitleActive UNIQUE (UserID, Title, IsActive);
