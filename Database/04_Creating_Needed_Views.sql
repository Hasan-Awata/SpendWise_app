USE SpendWiseDB;
GO

CREATE VIEW fin.vw_TransactionDetails AS
SELECT 
    t.TransactionID,
    t.UserID,
    t.TransactionDate,
    t.Amount,
    t.TransactionType,
    t.Description,
    -- جلب اسم الفئة (إن وجدت)
    c.Name AS CategoryName,
    -- جلب اسم الوسم/التاغ (إن وجد)
    tg.Name AS TagName,
    -- جلب اسم العملة للمحفظة اللي تمت منها العملية
    w.WalletID,
    cur.CurrencyName,
    -- جلب أسماء الكيانات المرتبطة للواجهة
    wk.Title AS WorkTitle,
    g.Title AS GoalTitle,
    o.Title AS ObligationTitle,
    d.Title AS DebtTitle
FROM fin.Transactions t
LEFT JOIN cfg.Categories c ON t.CategoryID = c.CategoryID
LEFT JOIN cfg.Tags tg ON t.TagID = tg.TagID
INNER JOIN fin.Wallets w ON t.WalletID = w.WalletID
INNER JOIN cfg.Currencies cur ON w.CurrencyID = cur.CurrencyID
LEFT JOIN pln.Works wk ON t.WorkID = wk.WorkID
LEFT JOIN pln.SavingsGoals g ON t.GoalID = g.GoalID
LEFT JOIN pln.FixedObligations o ON t.ObligationID = o.ObligationID
LEFT JOIN fin.SharedDebts d ON t.DebtID = d.DebtID;
GO

CREATE VIEW pln.vw_BudgetStatus AS
SELECT 
    b.BudgetID, 
    b.UserID, 
    c.Name AS CategoryName, 
    b.LimitAmount, 
    b.StartDate, 
    b.EndDate, 
    
    -- حساب المصروف الفعلي ضمن فترة الميزانية
    ISNULL((
        SELECT SUM(t.Amount) 
        FROM fin.Transactions t 
        WHERE t.UserID = b.UserID 
          AND t.CategoryID = b.CategoryID  
          AND t.TransactionType = 2 -- (افترضنا أن 2 تعني مصروف)
          AND CAST(t.TransactionDate AS DATE) BETWEEN b.StartDate AND b.EndDate
    ), 0) AS ActualSpent,

    -- حساب المتبقي من الميزانية
    (b.LimitAmount - ISNULL((
        SELECT SUM(t.Amount) 
        FROM fin.Transactions t 
        WHERE t.UserID = b.UserID 
          AND t.CategoryID = b.CategoryID  
          AND t.TransactionType = 2 
          AND CAST(t.TransactionDate AS DATE) BETWEEN b.StartDate AND b.EndDate
    ), 0)) AS RemainingAmount

FROM pln.Budgets b
INNER JOIN cfg.Categories c ON b.CategoryID = c.CategoryID;
GO

CREATE VIEW fin.vw_MonthlyCashFlow AS
SELECT 
    UserID,
    YEAR(TransactionDate) AS TransactionYear,
    MONTH(TransactionDate) AS TransactionMonth,
    -- جمع كل الدخل (افترضنا نوع الدخل = 1)
    ISNULL(SUM(CASE WHEN TransactionType = 1 THEN Amount ELSE 0 END), 0) AS TotalIncome,
    -- جمع كل المصاريف (افترضنا نوع المصروف = 2)
    ISNULL(SUM(CASE WHEN TransactionType = 2 THEN Amount ELSE 0 END), 0) AS TotalExpense,
    -- صافي الربح أو الخسارة للشهر
    ISNULL(SUM(CASE WHEN TransactionType = 1 THEN Amount ELSE 0 END), 0) - 
    ISNULL(SUM(CASE WHEN TransactionType = 2 THEN Amount ELSE 0 END), 0) AS NetSavings
FROM fin.Transactions
GROUP BY UserID, YEAR(TransactionDate), MONTH(TransactionDate);
GO

CREATE VIEW fin.vw_WalletSummary AS
SELECT 
    w.WalletID,
    w.UserID,
    cur.CurrencyName,
    w.Balance AS OriginalBalance,
    cur.ActualValue AS ExchangeRate,
    -- تحويل الرصيد للقيمة الأساسية الموحدة
    (w.Balance * cur.ActualValue) AS BaseCurrencyBalance
FROM fin.Wallets w
INNER JOIN cfg.Currencies cur ON w.CurrencyID = cur.CurrencyID;
GO