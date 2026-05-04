namespace SpendWise.Domain.Entities
{
    public class Currency
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty; // <-- Add this!
        public string CurrencyName { get; set; } = string.Empty;

        public Currency(int id, string code, string currencyName)
        {
            Id = id;
            Code = code;
            CurrencyName = currencyName;
        }

        public Currency() { }
    }
}