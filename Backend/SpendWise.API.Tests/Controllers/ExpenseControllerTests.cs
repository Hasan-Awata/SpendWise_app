using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using SpendWise.Application.DTOs.Wallet;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace SpendWise.API.Tests.Controllers
{
    public class ExpenseControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        private static string? _cachedToken;
        private static int _botUserId = 1;
        private static int _botWalletId = 1; // Pre-seeded matching our script
        private static bool _isAuthenticated = false;

        public ExpenseControllerTests(SpendWiseApiFactory factory)
        {
            _client = factory.CreateClient();
        }

        /// <summary>
        /// Highly optimized login flow. Skips costly registration chains and table inserts entirely.
        /// </summary>
        private async Task EnsureAuthenticatedViaLoginAsync()
        {
            if (_isAuthenticated && _cachedToken != null)
            {
                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken);
                return;
            }

            // Map login payload using the pre-seeded credentials
            var loginDto = new LoginDto
            {
                UserName = "reg_48d426",
                Password = "SecurePassword123!"
            };

            // Hit the login endpoint directly
            var loginResponse = await _client.PostAsJsonAsync("/api/Authentication/login", loginDto);
            if (!loginResponse.IsSuccessStatusCode)
            {
                var errorContext = await loginResponse.Content.ReadAsStringAsync();
                throw new HttpRequestException($"Test Suite Login Pre-condition Failed. Context: {errorContext}");
            }

            var authData = await loginResponse.Content.ReadFromJsonAsync<ResponseAuthDto>();
            _cachedToken = authData!.Token;

            _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken);
            _isAuthenticated = true;
        }

        [Fact]
        public async Task AddExpense_WithValidData_ReturnsCreated()
        {
            // Arrange
            await EnsureAuthenticatedViaLoginAsync();

            var expensePayload = new ExpenseDTO
            {
                Title = "Quick Coffee",
                Amount = 5000.00m,
                Date = DateTime.UtcNow,
                WalletId = _botWalletId,  // Hits our pre-funded 1,000,000 SYP wallet safely
                CategoryId = 1,
                Products = new List<ProductDTO> { new ProductDTO { Name = "Espresso", Quantity = 1, Price = 5000.00m } },
                ExpenseTagId = 1,
                UserId = _botUserId      // Explicitly matches our static User ID 999
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/expenses", expensePayload);
            var responseBody = await response.Content.ReadAsStringAsync();

            // Assert
            Assert.True(response.StatusCode == HttpStatusCode.Created,
                $"Expected 201 Created but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact]
        public async Task GetExpense_WhenExpenseDoesNotExist_ReturnsNotFound()
        {
            // Arrange
            await EnsureAuthenticatedViaLoginAsync();
            int nonExistentExpenseId = 999999;

            // Act
            var response = await _client.GetAsync($"/api/expenses/{nonExistentExpenseId}");
            var responseBody = await response.Content.ReadAsStringAsync();

            // Assert
            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }
    }
}