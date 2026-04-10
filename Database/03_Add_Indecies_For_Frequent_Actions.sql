USE SpendWiseDB;
GO

-- ==========================================
-- 1. Ledger Schema: The heaviest traffic tables
-- ==========================================

-- Optimizes: Fetching a user's transaction timeline (e.g., "Get my recent transactions")
-- Includes Amount, Type, and Category so EF Core projections (.Select) hit the index only.
CREATE NONCLUSTERED INDEX IX_Transactions_User_Date 
ON [Ledger].Transactions (UserID, TransactionDate DESC)
INCLUDE (Amount, TransactionType, CategoryID, WalletID, Title);
GO

-- Optimizes: Fetching all transactions for a specific wallet (to calculate or verify balances)
CREATE NONCLUSTERED INDEX IX_Transactions_Wallet
ON [Ledger].Transactions (WalletID, TransactionDate DESC)
INCLUDE (Amount, TransactionType);
GO

-- Optimizes: Fetching a user's specific expenses over time (e.g., Monthly Expense Chart)
CREATE NONCLUSTERED INDEX IX_Expenses_User_Date
ON [Ledger].Expenses (UserID, Date DESC)
INCLUDE (Amount, CategoryID, WalletID);
GO

-- Optimizes: Fetching a user's specific incomes over time
CREATE NONCLUSTERED INDEX IX_Incomes_User_Date
ON [Ledger].Incomes (UserID, Date DESC)
INCLUDE (Amount, WalletID);
GO

-- ==========================================
-- 2. Banking Schema
-- ==========================================

-- Optimizes: Fetching all wallets for the logged-in user to populate the dashboard
CREATE NONCLUSTERED INDEX IX_Wallets_User 
ON [Banking].Wallets (UserID)
INCLUDE (Balance, CurrencyID);
GO

-- ==========================================
-- 3. Planning Schema: Date-range lookups
-- ==========================================

-- Optimizes: Finding which budgets are currently active for a user today
CREATE NONCLUSTERED INDEX IX_Budgets_User_Dates
ON [Planning].Budgets (UserID, StartDate, EndDate)
INCLUDE (CategoryID, LimitAmount);
GO

-- Optimizes: Fetching upcoming fixed expenses sorted by due date
CREATE NONCLUSTERED INDEX IX_FixedExpenses_User_DueDate
ON [Planning].FixedExpenses (UserID, DueDate)
INCLUDE (Amount, Title, CategoryID)
WHERE IsActive = 1; -- Filtered index so we only scan active obligations
GO

-- Optimizes: Checking pending debts between users
CREATE NONCLUSTERED INDEX IX_SharedDebts_Debtor
ON [Planning].SharedDebts (DebtorID, DueDate)
INCLUDE (Amount, CreditorID, Status);
GO

CREATE NONCLUSTERED INDEX IX_SharedDebts_Creditor
ON [Planning].SharedDebts (CreditorID, DueDate)
INCLUDE (Amount, DebtorID, Status);
GO