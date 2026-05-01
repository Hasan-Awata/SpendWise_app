USE SpendWiseDB;

ALTER TABLE Config.Currencies
DROP CONSTRAINT CHK_Currencies_ActualValue;

ALTER TABLE Config.Currencies
DROP COLUMN ActualValue;