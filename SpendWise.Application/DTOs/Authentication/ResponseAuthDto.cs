using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Authentication
{
    public class ResponseAuthDto
    {
        public string Token { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty ;
        public DateTime Expiry { get; set; }
    }
}
