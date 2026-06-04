using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.Wallet;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Xunit;

namespace SpendWise.API.Tests.Controllers
{
    public class WalletControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        private static string? _cachedToken;
        private static int _botUserId = 1;
        private static int _botWalletId = 1; // Pre-seeded matching our script
        private static bool _isAuthenticated = false;

        public WalletControllerTests(SpendWiseApiFactory factory)
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
                var registerDto = new RegisterDto
                {
                    UserName = loginDto.UserName,
                    Password = loginDto.Password,
                    FirstName = "Test",
                    LastName = "Bot"
                };

                var registerResponse = await _client.PostAsJsonAsync("/api/Authentication/register", registerDto);
                if (!registerResponse.IsSuccessStatusCode)
                {
                    var errorContext = await loginResponse.Content.ReadAsStringAsync();
                    throw new HttpRequestException($"Test Suite Login Pre-condition Failed. Context: {errorContext}");
                }

                var loginRetry = await _client.PostAsJsonAsync("/api/Authentication/login", loginDto);
                if (!loginRetry.IsSuccessStatusCode)
                {
                    var errorContext = await loginRetry.Content.ReadAsStringAsync();
                    throw new HttpRequestException($"Test Suite Login Pre-condition Failed after register. Context: {errorContext}");
                }

                var authDataRetry = await loginRetry.Content.ReadFromJsonAsync<ResponseAuthDto>();
                _cachedToken = authDataRetry!.Token;

                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken);
                _isAuthenticated = true;
                return;
            }

            var authData = await loginResponse.Content.ReadFromJsonAsync<ResponseAuthDto>();
            _cachedToken = authData!.Token;

            _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken);
            _isAuthenticated = true;
        }

        [Fact(DisplayName = "Happy Path - Create Wallet returns 201 Created")]
        public async Task CreateWallet_HappyPath_ReturnsCreated()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 12,
                Balance = 1000.00m,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.Created,
                $"Expected 201 Created but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");

            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;

            Assert.True(root.TryGetProperty("walletId", out var idProp));
            Assert.True(idProp.GetInt32() > 0);

            Assert.True(root.TryGetProperty("userId", out var userIdProp));
            Assert.Equal(_botUserId, userIdProp.GetInt32());
        }

        [Fact(DisplayName = "Error Path - Create Wallet with already existed currency returns 409 Conflict")]
        public async Task CreateWallet_AlreadyExistedCurrency_ReturnsConflict()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 1,
                Balance = 1000.00m,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.Conflict,
                $"Expected 409 Conflict but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Error Path - Create Wallet with invalid currency returns 400 BadRequest")]
        public async Task CreateWallet_InvalidCurrency_ReturnsBadRequest()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 9999, // non-existent currency
                Balance = 10.00m,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.BadRequest,
                $"Expected 400 BadRequest but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Validation - Create Wallet with negative balance returns 400 BadRequest")]
        public async Task CreateWallet_NegativeBalance_ReturnsBadRequest()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 1,
                Balance = -100.00m,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.BadRequest,
                $"Expected 400 BadRequest but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Security - Malicious user payload mismatch returns Unauthorized")]
        public async Task CreateWallet_UserMismatch_ReturnsUnauthorized()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 1,
                Balance = 50.00m,
                UserId = _botUserId + 1, // mismatch
                IsSaved = false
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.Unauthorized,
                $"Expected 401 Unauthorized but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Error Path - Create Wallet with amount exceeding DECIMAL(18,2) precision results in server error")]
        public async Task CreateWallet_AmountOverflow_ReturnsServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var hugeAmount = decimal.Parse("99999999999999999.99");

            var dto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 1,
                Balance = hugeAmount,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PostAsJsonAsync("/api/wallets", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.InternalServerError,
                $"Expected 500 InternalServerError but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Get Wallet - Non-existent wallet returns 404 NotFound")]
        public async Task GetWallet_NonExistent_ReturnsNotFound()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.GetAsync($"/api/wallets/999999");
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Get User Wallets - Happy Path returns 200 Ok and an array")]
        public async Task GetUserWallets_HappyPath_ReturnsOk()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.GetAsync("/api/wallets");
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.OK,
                $"Expected 200 OK but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");

            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;
            Assert.True(root.ValueKind == JsonValueKind.Array, "Expected response to be a JSON array of wallets.");
        }

        [Fact(DisplayName = "Update Wallet - Happy Path returns 200 Ok")]
        public async Task UpdateWallet_HappyPath_ReturnsOk()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = _botWalletId,
                CurrencyId = 1,
                Balance = 5000.00m,
                UserId = _botUserId,
                IsSaved = false
            };

            var response = await _client.PatchAsJsonAsync($"/api/wallets/{_botWalletId}", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.OK,
                $"Expected 200 OK but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");

            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;
            Assert.True(root.TryGetProperty("walletId", out var idProp));
            Assert.Equal(_botWalletId, idProp.GetInt32());
        }

        [Fact(DisplayName = "Update Wallet - Invalid currency returns 400 BadRequest")]
        public async Task UpdateWallet_InvalidCurrency_ReturnsBadRequest()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new WalletDTO
            {
                WalletId = _botWalletId,
                CurrencyId = 9999,
                Balance = 10.00m,
                UserId = _botUserId,
                IsSaved = true
            };

            var response = await _client.PatchAsJsonAsync($"/api/wallets/{_botWalletId}", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.BadRequest,
                $"Expected 400 BadRequest but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Delete Wallet - Happy Path (create then delete) returns 204 NoContent")]
        public async Task DeleteWallet_HappyPath_CreateThenDelete_ReturnsNoContent()
        {
            await EnsureAuthenticatedViaLoginAsync();

            // Create a wallet to delete safely
            var createDto = new WalletDTO
            {
                WalletId = -1,
                CurrencyId = 7,
                Balance = 1.00m,
                UserId = _botUserId,
                IsSaved = false
            };

            var createResponse = await _client.PostAsJsonAsync("/api/wallets", createDto);
            var createBody = await createResponse.Content.ReadAsStringAsync();
            Assert.True(createResponse.StatusCode == HttpStatusCode.Created, $"Failed to create wallet for delete test. Body: {createBody}");

            using var doc = JsonDocument.Parse(createBody);
            var createdId = doc.RootElement.GetProperty("walletId").GetInt32();

            var deleteResponse = await _client.DeleteAsync($"/api/wallets/{createdId}");
            var deleteBody = await deleteResponse.Content.ReadAsStringAsync();

            Assert.True(deleteResponse.StatusCode == HttpStatusCode.NoContent,
                $"Expected 204 NoContent but got {(int)deleteResponse.StatusCode} {deleteResponse.StatusCode}. Response body: {deleteBody}");
        }

        [Fact(DisplayName = "Delete Wallet - Non-existent wallet returns Server Error")]
        public async Task DeleteWallet_NonExistent_ReturnsServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.DeleteAsync($"/api/wallets/-99999");
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.InternalServerError,
                $"Expected 500 InternalServerError but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }
    }
}
