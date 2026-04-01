using SpendWise.Application.Interfaces.Users;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Domain.Entities;

namespace SpendWise.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        public async Task<User?> GetByIdAsync(int id)
        {
            throw new NotImplementedException();
        }
        public async Task<User?> GetByUsernameAsync(string userName)
        {
            throw new NotImplementedException();
        }
        public async Task<bool> IsUsernameExistAsync(string username)
        {
            throw new NotImplementedException();
        }
        public async Task AddUserAsync(User user)
        {
            throw new NotImplementedException();
        }
    }
}
