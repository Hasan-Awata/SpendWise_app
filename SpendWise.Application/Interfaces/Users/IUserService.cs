using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs;
using SpendWise.Domain.Entities;

namespace SpendWise.Application.Interfaces.Users
{
    public interface IUserService
    {
        public Task AddUserAsync(UserDTO user);
        public Task<User?> GetByUsernameAsync(string userName);
        public Task<User?> GetByIdAsync(int id);
        public Task<bool> IsUsernameExistAsync(string username);
    }
}
