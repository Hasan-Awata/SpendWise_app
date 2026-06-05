using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.User
{
    public class UpdateTokenRequest
    {
        public int UserId { get; set; }
        public string FcmToken { get; set; } = string.Empty;
    }
}