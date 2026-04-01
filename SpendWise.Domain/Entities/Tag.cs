using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Tag
    {
        public int Id { get; set; } = -1;
        public int CategoryId { get; set; } = -1;
        public int OwnerId { get; set; } = -1;
        public string Label { get; set; } = string.Empty;
    }
}
