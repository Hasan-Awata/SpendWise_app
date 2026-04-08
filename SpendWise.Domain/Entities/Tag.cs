using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Domain.Entities
{
    public class Tag
    {
        public int Id { get; set; } = -1;
        public int OwnerId { get; set; } = -1;
        public string Label { get; set; } = string.Empty;
        public Tag(int  id,int ownerID, string label)
        {
            Id = id;
            OwnerId = ownerID;
            Label = label;
        }
    }
}
