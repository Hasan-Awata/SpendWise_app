using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces
{
    public interface IUserRepository
    {
        public Task AddUserAsync(User user);
        public Task<User?> GetByUsernameAsync(string userName);
        public Task<User?> GetByIdAsync(int id);
        public Task<bool> UsernameExistsAsync(string username);

    }
}
