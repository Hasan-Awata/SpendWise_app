using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace SpendWise.API.Tests.Controllers
{
    public class ExpenseControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        public ExpenseControllerTests(SpendWiseApiFactory factory)
        {
            _client = factory.CreateClient();
        }

        /// <summary>
        /// Helper utility to isolate test sessions by creating a clean user,
        /// retrieving their JWT token, and attaching it to request headers.
        /// </summary>
        private async Task AuthenticateClientAsync()
        {
            var uniqueUser = $"test_expense_user_{Guid.NewGuid().ToString()[..8]}";
            var registerDto = new RegisterDto
            {
                UserName = uniqueUser,
                Password = "SecurePassword123!",
                FirstName = "Expense",
                LastName = "Tester"
            };

            // Register and extract auth token payloads
            var authResponse = await _client.PostAsJsonAsync("/api/Authentication/register", registerDto);
            authResponse.EnsureSuccessStatusCode();

            var authData = await authResponse.Content.ReadFromJsonAsync<ResponseAuthDto>();

            // Inject JWT Bearer Token into HttpClient authorizations
            _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", authData!.Token);
        }

        [Fact]
        public async Task AddExpense_WithValidData_ReturnsCreatedAtAction()
        {
            // Arrange
            await AuthenticateClientAsync();

            var expensePayload = new ExpenseDTO
            {
                Title = "Coffee Break",
                Amount = 15000.00m,
                Date = DateTime.UtcNow,
                WalletId = 1,          // Ensure this matches a valid seed ID in your test database setup
                CategoryId = 1,        // e.g., Essentials
                Products = new List<ProductDTO> { new ProductDTO { Name = "Espresso" }, new ProductDTO { Name = "Croissant" } },
                ExpenseTagId = 1
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/expenses", expensePayload);

            // Assert
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);

            var createdExpense = await response.Content.ReadFromJsonAsync<ExpenseResponse>();
            Assert.NotNull(createdExpense);
            Assert.True(createdExpense.ExpenseId > 0);
            Assert.Equal("Coffee Break", createdExpense.Title);
        }

        [Fact]
        public async Task GetExpense_WhenExpenseDoesNotExist_ReturnsNotFound()
        {
            // Arrange
            await AuthenticateClientAsync();
            int nonExistentExpenseId = 999999;

            // Act
            var response = await _client.GetAsync($"/api/expenses/{nonExistentExpenseId}");

            // Assert
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        }

        [Fact]
        public async Task UpdateExpense_WithMismatchedOrMaliciousUserContext_ReturnsUnauthorized()
        {
            // Arrange
            await AuthenticateClientAsync();

            var maliciousPayload = new ExpenseDTO
            {
                ExpenseId = 5,
                UserId = 888, // Intentional mismatch with current authorized User Claim ID
                Title = "Malicious Hijack Try",
                Amount = 500000.00m
            };

            // Act
            var response = await _client.PatchAsJsonAsync("/api/expenses/5", maliciousPayload);

            // Assert
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }

        [Fact]
        public async Task DeleteExpense_WithoutAuthHeaders_ReturnsUnauthorized()
        {
            // Arrange
            _client.DefaultRequestHeaders.Authorization = null; // Ensure clean state
            int targetedExpenseId = 10;

            // Act
            var response = await _client.DeleteAsync($"/api/expenses/{targetedExpenseId}");

            // Assert
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }
    }
}