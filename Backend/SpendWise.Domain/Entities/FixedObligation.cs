namespace SpendWise.Domain.Entities
{
    public class FixedObligation
    {
        public FixedObligation(int fixedObligationId, int userId, int walletId, string title, decimal amount, bool isMonthly, bool isActive, int? days, DateTime? lastTime)
        {
            FixedObligationId = fixedObligationId;
            UserId = userId;
            WalletId = walletId;
            Title = title;
            Amount = amount;
            IsMonthly = isMonthly;
            IsActive = isActive;
            Days = days;
            LastTime = lastTime;
        }

        public int FixedObligationId { get; set; }
        public int UserId { get; set; }
        public int WalletId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public bool IsMonthly { get; set; }
        public bool IsActive { get; set; } = true;
        public int? Days { get; set; }
        public DateTime? LastTime { get; set; }
    }
}