using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using SpendWise.Domain.Entities;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Application.Interfaces.Authentication;
using SpendWise.Application.DTOs.Authentication;

namespace SpendWise.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRepository _userRepo;
        private readonly IConfiguration _configuration;

        // ── Private helper: builds the JWT token ─────────────────────────
        private ResponseAuthDto GenerateToken(User user)
        {
            // Read config values from appsettings.json
            var issuer = _configuration["JwtSettings:Issuer"]!;
            var audience = _configuration["JwtSettings:Audience"]!;
            var secretKey = _configuration["JwtSettings:SecretKey"]!;
            var expiryMin = int.Parse(_configuration["JwtSettings:ExpiryInMinutes"]!);

            // Convert the secret key string into a cryptographic signing key
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // Claims are the data embedded inside the token payload
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub,   user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.PreferredUsername, user.UserName),
                new Claim(JwtRegisteredClaimNames.Jti,   Guid.NewGuid().ToString()),
            };

            var expiry = DateTime.UtcNow.AddMinutes(expiryMin);

            // Build the token object
            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expiry,
                signingCredentials: creds
            );

            // Serialize the token to its string form (the three-part dot-separated value)
            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

            return new ResponseAuthDto
            {
                Token = tokenString,
                UserId = user.Id,
                UserName = user.UserName,
                Expiry = expiry
            };
        }

        public AuthService(IUserRepository userRepo, IConfiguration configuration)
        {
            _configuration = configuration;
            _userRepo = userRepo;
        }

        public async Task<ResponseAuthDto> RegisterAsync(RegisterDto registerDto)
        {
            if (await _userRepo.IsUsernameExistAsync(registerDto.UserName))
                throw new InvalidOperationException("This username is already taken.");

            var Hashedpassword = BCrypt.Net.BCrypt.HashPassword(registerDto.Password);

            var user = new User(registerDto.UserName, Hashedpassword, registerDto.FirstName, registerDto.LastName);

            await _userRepo.AddUserAsync(user);

            return GenerateToken(user);
        }

        public async Task<ResponseAuthDto?> LoginAsync(LoginDto loginDto)
        {
            var user = await _userRepo.GetByUsernameAsync(loginDto.UserName);

            if (user == null) return null;

            var passwordIsValid = BCrypt.Net.BCrypt.Verify(loginDto.Password, user.HashedPassword);

            if (!passwordIsValid) return null;

            return GenerateToken(user);
        }
    }
}
