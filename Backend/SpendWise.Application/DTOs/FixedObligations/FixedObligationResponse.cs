namespace SpendWise.Application.DTOs.FixedObligations
{
    public class FixedObligationResponse
    {
        public int FixedObligationId { get; set; }
        public int UserId { get; set; }
        public int WalletId { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public bool IsMonthly { get; set; }
        public bool IsActive { get; set; }
        public int? Days { get; set; }
        public DateTime? LastTime { get; set; }
    }
}