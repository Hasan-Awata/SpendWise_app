using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace SpendWise.Application.DTOs.Tag
{
    public class TagResponse
    {
        public int Id { get; set; }
        public string Label { get; set; } = string.Empty;
        public int OwnerId { get; set; }

        public TagResponse(int id, string label, int ownerId)
        {
            Id = id;
            Label = label;
            OwnerId = ownerId;
        }
    }
}
