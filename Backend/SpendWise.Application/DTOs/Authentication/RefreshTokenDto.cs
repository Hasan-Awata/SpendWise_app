using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.DTOs.Authentication
{
    public class RefreshTokenDto
    {
        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
    }
}
