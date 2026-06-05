using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Users
{
    public interface IUserRepository
    {
        public Task<int> AddUserAsync(User user);
        public Task<User?> GetByUsernameAsync(string userName);
        public Task<User?> GetByIdAsync(int id);
        public Task<bool> IsUsernameExistAsync(string username);
        public Task<bool> UpdateRefreshTokenAsync(int userId, string refreshToken, DateTime refreshTokenExpiryTime); 
        public Task<bool> UpdateFcmTokenAsync(int userId, string fcmToken);
    }
}
