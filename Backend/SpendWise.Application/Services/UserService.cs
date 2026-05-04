using SpendWise.Application.DTOs.User;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _UserRepo;
        public UserService(IUserRepository userRepo)
        {
            _UserRepo = userRepo;
        }
        public async Task<User?> GetByIdAsync(int id)
        {
            var user = await _UserRepo.GetByIdAsync(id);
            return user;
        }
        public async Task<User?> GetByUsernameAsync(string userName)
        {
            var user = await _UserRepo.GetByUsernameAsync(userName);
            return user;
        }
        public async Task AddUserAsync(UserDTO userDTO)
        {
            var NewUser = new User(userDTO.Id, userDTO.Username);
            await _UserRepo.AddUserAsync(NewUser);
        }
        public async Task<bool> IsUsernameExistAsync(string username)
        {
            var isExist = await _UserRepo.IsUsernameExistAsync(username);
            return isExist;
        }
    }
}
