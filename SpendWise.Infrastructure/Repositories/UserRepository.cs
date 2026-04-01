using SpendWise.Application.Interfaces;
using Microsoft.EntityFrameworkCore;

using SpendWise.Domain.Entities;

namespace SpendWise.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        public readonly ApplicationDbContext _context; // Inject the database connection here 
        public UserRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task AddUserAsync(User user)
        {
            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();
        }

        public async Task<User?> GetByUsernameAsync(string username)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.UserName == username);
        }
        
        public async Task<User?> GetByIdAsync(int id)
        {
            return await _context.Users.FindAsync(id);
        }

        public async Task<bool> UsernameExistsAsync(string username)
        {
            return await _context.Users.AnyAsync(u => u.UserName == username);
        }
    } 
}

