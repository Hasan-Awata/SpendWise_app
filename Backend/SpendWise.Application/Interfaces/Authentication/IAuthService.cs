using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.User;

namespace SpendWise.Application.Interfaces.Authentication
{
    public interface IAuthService
    {
        public Task<ResponseAuthDto> RegisterAsync(RegisterDto registerDto);
        public Task<ResponseAuthDto?> LoginAsync(LoginDto loginDto);
        Task<ResponseAuthDto?> RefreshTokenAsync(RefreshTokenDto tokenDto);
        public Task<bool> UpdateFcmTokenAsync(UpdateTokenRequest request);
    }
}
