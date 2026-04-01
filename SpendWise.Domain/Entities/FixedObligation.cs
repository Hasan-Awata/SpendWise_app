using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class FixedObligation
    {
        public int Id { get; set; } = -1;
        public int OwnerId { get; set; } = -1;
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public DateTime DueDate { get; set; }
        public bool IsActive { get; set; }
    }
}
