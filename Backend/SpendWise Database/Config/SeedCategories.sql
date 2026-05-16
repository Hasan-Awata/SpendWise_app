/* 1. Allow manual ID insertion */
SET IDENTITY_INSERT [Config].[Categories] ON;

/* 2. Insert initial values*/
MERGE INTO [Config].[Categories] AS Target
USING (VALUES 
    (1, 'Essentials', 1),
    (2, 'Secondaries', 2),
    (3, 'Luxuries', 3),    
    (4, 'Savings', 4)
) AS Source (CategoryID, CategoryName, CategoryPriority)
ON (Target.CategoryID = Source.CategoryID) 
WHEN MATCHED THEN
    UPDATE SET 
        [Name] = Source.CategoryName,
        [Priority] = Source.CategoryPriority
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([CategoryID], [Name], [Priority])
    VALUES (Source.CategoryID, Source.CategoryName, Source.CategoryPriority); -- Fixed: matched source names

/* 3. Turn manual ID insertion back off */
SET IDENTITY_INSERT [Config].[Categories] OFF;