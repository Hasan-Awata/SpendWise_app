USE SpendWiseDB;
GO

-- 1. View: تفاصيل العمليات المالية الشاملة
CREATE VIEW fin.vw_TransactionDetails AS
SELECT t.TransactionID, u.UserID, t.Amount, tg.Name AS TagName, t.Description, t.TransactionType, t.TransactionDate
FROM     fin.Transactions AS t INNER JOIN
         usr.Users AS u ON t.UserID = u.UserID INNER JOIN
         cfg.Tags AS tg ON t.TagID = tg.TagID;
go

-- 2. View: تفاصيل الديون المشتركة
CREATE VIEW fin.vw_SharedDebtsDetails AS
SELECT d.DebtID, d.Amount, cr.FirstName + ' ' + cr.LastName AS CreditorName, db.FirstName + ' ' + db.LastName AS DebtorName, d.Description, d.Status, d.DueDate, d.CreatedAt
FROM     fin.SharedDebts AS d INNER JOIN
                  usr.Users AS cr ON d.CreditorID = cr.UserID INNER JOIN
                  usr.Users AS db ON d.DebtorID = db.UserID;
go

-- 3. View: حالة الميزانيات ونسبة الاستهلاك
CREATE VIEW pln.vw_BudgetStatus AS
SELECT b.BudgetID, b.UserID, c.Name AS CategoryName, b.Month, b.Year, b.LimitAmount, b.Percentage, ISNULL
                      ((SELECT SUM(t.Amount) AS Expr1
                        FROM      fin.Transactions AS t INNER JOIN
                                          cfg.Tags AS tg ON t.TagID = tg.TagID
                        WHERE   (t.UserID = b.UserID) AND (tg.CategoryID = b.CategoryID) AND (MONTH(t.TransactionDate) = b.Month) AND (YEAR(t.TransactionDate) = b.Year)), 0) AS ActualSpent
FROM     pln.Budgets AS b INNER JOIN
                  cfg.Categories AS c ON b.CategoryID = c.CategoryID;
go