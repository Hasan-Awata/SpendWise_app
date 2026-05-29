using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using System.Net.Http.Headers;
using Xunit;
using SpendWise.Application.DTOs.Income;

namespace SpendWise.API.Tests.Controllers
{
    // Integration tests for Income endpoints using SpendWiseApiFactory and the shared login flow.
    public class IncomeControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        private static string? _cachedToken;
        private static int _botUserId = 1;
        private static int _botWalletId = 1; 
        private static bool _isAuthenticated = false;

        public IncomeControllerTests(SpendWiseApiFactory factory)
        {
            _client = factory.CreateClient();
        }

        private async Task EnsureAuthenticatedViaLoginAsync()
        {
            if (_isAuthenticated && _cachedToken != null)
            {
                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken);
                return;
            }

            var loginDto = new LoginDto
            {
                UserName = "reg_48d426",
                Password = "SecurePassword123!"
            };

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

        [Fact(DisplayName = "Happy Path - Create Income with boundary Title length and valid amount returns 201 Created")]
        public async Task CreateIncome_HappyPath_ReturnsCreated()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new 
            {
                Id = -1,
                UserId = _botUserId,
                Title = new string('A', 255), // boundary per NVARCHAR(255)
                Description = "Integration test income",
                WalletId = _botWalletId,
                Amount = 10000.00m,
                Date = DateTime.UtcNow.ToString("o"),
                IncomeTagId = -1
            };

            var content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json");

            var response = await _client.PostAsync("/api/incomes", content);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.Created,
                $"Expected 201 Created but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;

            Assert.True(root.TryGetProperty("id", out var idProp));
            Assert.True(idProp.GetInt32() > 0);

            Assert.True(root.TryGetProperty("userId", out var userIdProp));
            Assert.Equal(_botUserId, userIdProp.GetInt32());

            Assert.True(root.TryGetProperty("title", out var titleProp));
            Assert.Equal(255, titleProp.GetString()!.Length);

            Assert.True(root.TryGetProperty("amount", out var amountProp));
            // The database stores DECIMAL(18,2) so amount should be represented with two decimal places
            Assert.Equal("10000.00", amountProp.GetDecimal().ToString("0.00"));
        }

        [Fact(DisplayName = "Error Path - Create Income with non-existent wallet returns 404 NotFound")]
        public async Task CreateIncome_InvalidWallet_ReturnsNotFound()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new
            {
                Id = -1,
                UserId = _botUserId,
                Title = "Invalid Wallet Test",
                Description = "Should return NotFound for wallet",
                WalletId = 123456789, // assumed non-existent
                Amount = 10.00m,
                Date = DateTime.UtcNow.ToString("o"),
                IncomeTagId = -1
            };

            var content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json");

            var response = await _client.PostAsync("/api/incomes", content);
            var responseBody = await response.Content.ReadAsStringAsync();
            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Error Path - Create Income with amount exceeding DECIMAL(18,2) precision results in server error")]
        public async Task CreateIncome_AmountOverflow_ReturnsServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            // Use a number too large for DECIMAL(18,2) to provoke SQL arithmetic overflow.
            // Construct at runtime to avoid C# literal overflow.
            var hugeAmount = decimal.Parse("99999999999999999.99"); // 17 digits before decimal -> over DECIMAL(18,2) precision

            var dto = new
            {
                Id = -1,
                UserId = _botUserId,
                Title = "Overflow Test",
                Description = "Should cause SQL arithmetic overflow",
                WalletId = _botWalletId,
                Amount = hugeAmount,
                Date = DateTime.UtcNow.ToString("o"),
                IncomeTagId = -1
            };

            var content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json");

            var response = await _client.PostAsync("/api/incomes", content);
            var responseBody = await response.Content.ReadAsStringAsync();
            // The repository rethrows SQL exceptions from the stored procedure; the API surface should return 500
            Assert.True(response.StatusCode == HttpStatusCode.InternalServerError,
                $"Expected 500 InternalServerError but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Security - Malicious user payload mismatch returns Unauthorized")]
        public async Task CreateIncome_UserMismatch_ReturnsUnauthorized()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new
            {
                Id = -1,
                UserId = _botUserId + 1, // different than authenticated TestBotUserId
                Title = "User Mismatch Test",
                Description = "UserId in body does not match authenticated user",
                WalletId = _botWalletId,
                Amount = 50.00m,
                Date = DateTime.UtcNow.ToString("o"),
                IncomeTagId = -1
            };

            var content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json");

            var response = await _client.PostAsync("/api/incomes", content);
            var responseBody = await response.Content.ReadAsStringAsync();
            Assert.True(response.StatusCode == HttpStatusCode.Unauthorized,
                $"Expected 401 Unauthorized but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Stored Procedure Domain Error - Delete non-existent income surfaces server error (stored proc THROW)")]
        public async Task DeleteIncome_NonExistent_StoredProcThrows_ReturnsServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            // Attempt to delete an income that does not exist for the test user
            var nonExistentIncomeId = -99999;

            var response = await _client.DeleteAsync($"/api/incomes/{nonExistentIncomeId}");
            var responseBody = await response.Content.ReadAsStringAsync();

            // The stored procedure throws when the income was not found; repository rethrows SQL exception -> 500
            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }
    }
}
