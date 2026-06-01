CREATE TRIGGER [trg_PaidAmountChangedForDebt]
	ON [Planning].[SharedDebts]
	AFTER UPDATE
	AS
	BEGIN
		IF UPDATE(PaidAmount)
		BEGIN
			UPDATE sd
			SET sd.Status = 'Paid'
			FROM [Planning].SharedDebts sd
			INNER JOIN inserted i ON sd.DebtID = i.DebtID
			WHERE i.PaidAmount = i.Amount;
		END
	END
