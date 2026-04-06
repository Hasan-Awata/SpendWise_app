USE SpendWiseDB;
GO

-- ==============================================================
-- 1. الفهارس الأساسية لجدول العمليات (Transactions)
-- ==============================================================

-- تسريع شاشة عرض السجل اليومي (ترتيب العمليات للمستخدم حسب التاريخ)
CREATE NONCLUSTERED INDEX IX_Transactions_UserID_Date 
ON fin.Transactions (UserID ASC, TransactionDate DESC);
GO

-- تسريع عرض حركات محفظة محددة
CREATE NONCLUSTERED INDEX IX_Transactions_WalletID 
ON fin.Transactions (WalletID ASC);
GO

-- تسريع الفلترة حسب الوسم (Tag)
CREATE NONCLUSTERED INDEX IX_Transactions_TagID 
ON fin.Transactions (TagID ASC);
GO

-- ==============================================================
-- 2. الفهرس المغطي (Covering Index) الأقوى لحساب الميزانية والـ Dashboard
-- ==============================================================
CREATE NONCLUSTERED INDEX IX_Transactions_User_Category_Date_Covering 
ON fin.Transactions (UserID ASC, CategoryID ASC, TransactionDate DESC)
INCLUDE (Amount, TransactionType); 
GO

-- ==============================================================
-- 3. الفهارس المفلترة الذكية (Filtered Indexes) للمفاتيح الاختيارية
-- ==============================================================
CREATE NONCLUSTERED INDEX IX_Transactions_GoalID_Filtered 
ON fin.Transactions (GoalID ASC) 
WHERE GoalID IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX IX_Transactions_DebtID_Filtered 
ON fin.Transactions (DebtID ASC) 
WHERE DebtID IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX IX_Transactions_ObligationID_Filtered 
ON fin.Transactions (ObligationID ASC) 
WHERE ObligationID IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX IX_Transactions_WorkID_Filtered 
ON fin.Transactions (WorkID ASC) 
WHERE WorkID IS NOT NULL;
GO

-- إضافة الفهرس المفلتر لجدول المصاريف المستقلة (بناءً على التعديل الأخير)
CREATE NONCLUSTERED INDEX IX_Transactions_ExpenseID_Filtered 
ON fin.Transactions (ExpenseID ASC) 
WHERE ExpenseID IS NOT NULL;
GO

-- ==============================================================
-- 4. فهارس الجداول المحيطية (لتسريع جلب القوائم والـ JOINs)
-- ==============================================================

-- تسريع فلترة الالتزامات الثابتة للمستخدم
CREATE NONCLUSTERED INDEX IX_FixedObligations_UserID 
ON pln.FixedObligations (UserID ASC);
GO

-- تسريع جلب الديون المرتبطة بمستخدم (سواء كان دائن أو مدين)
CREATE NONCLUSTERED INDEX IX_SharedDebts_CreditorID 
ON fin.SharedDebts (CreditorID ASC);
GO

CREATE NONCLUSTERED INDEX IX_SharedDebts_DebtorID 
ON fin.SharedDebts (DebtorID ASC);
GO

-- تسريع جلب أهداف الادخار
CREATE NONCLUSTERED INDEX IX_SavingsGoals_UserID 
ON pln.SavingsGoals (UserID ASC);
GO

-- تسريع جلب الأعمال/مصادر الدخل
CREATE NONCLUSTERED INDEX IX_Works_UserID 
ON pln.Works (UserID ASC);
GO