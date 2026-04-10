using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Authentication;

namespace SpendWise.Application.Interfaces.Authentication
{
    public interface IAuthService
    {
        public Task<ResponseAuthDto> RegisterAsync(RegisterDto registerDto);
        public Task<ResponseAuthDto?> LoginAsync(LoginDto loginDto);
    }
}
