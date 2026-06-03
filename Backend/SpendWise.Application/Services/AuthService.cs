using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.User;
using SpendWise.Application.Interfaces.Authentication;
using SpendWise.Application.Interfaces.Users;
using SpendWise.Domain.Entities;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

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
                UserId = -1,
                UserName = user.UserName,
                Expiry = expiry
            };
        }

        // ── Helper: Generates a cryptographically secure random string ─────────────────────
        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        // ── Helper: Reads expired JWT tokens without crashing on expiration ────────────────
        private ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            var secretKey = _configuration["JwtSettings:SecretKey"]!;

            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = true,
                ValidAudience = _configuration["JwtSettings:Audience"],
                ValidateIssuer = true,
                ValidIssuer = _configuration["JwtSettings:Issuer"],
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                ValidateLifetime = false // Crucial: We WANT to read the token even if it's expired
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

            // Ensure the token has actually been signed using the correct algorithm
            if (securityToken is not JwtSecurityToken jwtSecurityToken ||
                !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
            {
                throw new SecurityTokenException("Invalid token signature");
            }

            return principal;
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

            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(registerDto.Password);
            var user = new User(registerDto.UserName, hashedPassword, registerDto.FirstName, registerDto.LastName);

            int userId = await _userRepo.AddUserAsync(user);
            user.Id = userId; // Important: Make sure the User object has its ID before generating the token

            var responseAuth = GenerateToken(user);
            responseAuth.UserId = userId;

            // ── Generate and save the refresh token
            var refreshToken = GenerateRefreshToken();
            var expiry = DateTime.UtcNow.AddDays(7);

            await _userRepo.UpdateRefreshTokenAsync(userId, refreshToken, expiry);

            responseAuth.RefreshToken = refreshToken;

            return responseAuth;
        }

        public async Task<ResponseAuthDto?> LoginAsync(LoginDto loginDto)
        {
            var user = await _userRepo.GetByUsernameAsync(loginDto.UserName);
            if (user == null) return null;

            var passwordIsValid = BCrypt.Net.BCrypt.Verify(loginDto.Password, user.HashedPassword);
            if (!passwordIsValid) return null;

            var responseAuth = GenerateToken(user);
            responseAuth.UserId = user.Id;

            // ── Generate and save the refresh token
            var refreshToken = GenerateRefreshToken();
            var expiry = DateTime.UtcNow.AddDays(7);

            await _userRepo.UpdateRefreshTokenAsync(user.Id, refreshToken, expiry);

            responseAuth.RefreshToken = refreshToken;

            return responseAuth;
        }

        public async Task<ResponseAuthDto?> RefreshTokenAsync(RefreshTokenDto tokenDto)
        {
            try
            {
                // 1. Get the claims principal from the expired access token
                var principal = GetPrincipalFromExpiredToken(tokenDto.AccessToken);
                if (principal == null) return null;

                // 2. Extract the User ID from the Sub claim
                var userIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier) ?? principal.FindFirst(JwtRegisteredClaimNames.Sub);
                if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId)) return null;

                // 3. Fetch the user from the database
                var user = await _userRepo.GetByIdAsync(userId);

                // 4. Strictly validate the user and the incoming refresh token
                if (user == null ||
                    user.RefreshToken != tokenDto.RefreshToken ||
                    user.RefreshTokenExpiryTime <= DateTime.UtcNow)
                {
                    return null; // Token has been tampered with or has expired
                }

                // 5. Generate a fresh pair of tokens
                var responseAuth = GenerateToken(user);
                responseAuth.UserId = user.Id;

                var newRefreshToken = GenerateRefreshToken();
                var newExpiry = DateTime.UtcNow.AddDays(7);

                // 6. Persist the new refresh token to the database
                await _userRepo.UpdateRefreshTokenAsync(user.Id, newRefreshToken, newExpiry);

                responseAuth.RefreshToken = newRefreshToken;

                return responseAuth;
            }
            catch (Exception)
            {
                return null; // Catch parsing or validation exceptions gracefully
            }
        }
        public async Task<bool> UpdateFcmTokenAsync(UpdateTokenRequest request)
        {
            try
            {
                var user = await _userRepo.GetByIdAsync(request.UserId);
                if (user == null) return false;
                user.FcmToken = request.FcmToken;
                await _userRepo.UpdateFcmTokenAsync(request.UserId, request.FcmToken);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
