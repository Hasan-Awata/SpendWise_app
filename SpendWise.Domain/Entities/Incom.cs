using SpendWise.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Incom
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public enIncomeType enIncomeType { get; set; }
        public DateTime? Repetition { get; set; } // How frequent does this Incom repeat.
    }
}
