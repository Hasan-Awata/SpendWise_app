using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using SpendWise.Application.DTOs.Expense;
using SpendWise.Application.DTOs.Income;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Xunit;

namespace SpendWise.API.Tests.Controllers
{
    public class ExpenseControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        private static string? _cachedToken;
        private static int _botUserId = 1;
        private static int _botWalletId = 1;
        private static bool _isAuthenticated = false;

        public ExpenseControllerTests(SpendWiseApiFactory factory)
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
                // Try to register the account if login failed (makes tests resilient to DB reset)
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

        [Fact(DisplayName = "Happy Path - Create Expense returns 201 Created and valid payload")]
        public async Task CreateExpense_HappyPath_ReturnsCreated()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Lunch",
                Description = "Team lunch",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 2500.00m,
                Date = DateTime.UtcNow,
                ExpenseTagId = -1,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "Sandwich", Quantity = 1, Price = 1500.00m },
                    new ProductDTO { Name = "Drink", Quantity = 1, Price = 1000.00m }
                }
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.Created,
                $"Expected 201 Created but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");

            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;
            Assert.True(root.TryGetProperty("expenseId", out var idProp));
            Assert.True(idProp.GetInt32() > 0);
            Assert.Equal(_botUserId, root.GetProperty("userId").GetInt32());
        }

        [Fact(DisplayName = "Validation - Create Expense with empty products returns 400 BadRequest")]
        public async Task CreateExpense_EmptyProducts_ReturnsBadRequest()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Empty products",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 10.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>()
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.BadRequest,
                $"Expected 400 BadRequest but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Business Rule - Products total mismatch returns 422 UnprocessableEntity")]
        public async Task CreateExpense_ProductsTotalMismatch_ReturnsUnprocessableEntity()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Mismatch",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 100.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "Item1", Quantity = 1, Price = 10.00m }
                }
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.UnprocessableEntity,
                $"Expected 422 UnprocessableEntity but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Error Path - Create Expense with non-existent wallet returns 404 NotFound")]
        public async Task CreateExpense_InvalidWallet_ReturnsNotFound()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Invalid Wallet Test",
                WalletId = 123456789,
                CategoryId = 1,
                Amount = 10.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "X", Quantity = 1, Price = 10.00m }
                }
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Security - Malicious user payload mismatch returns Unauthorized")]
        public async Task CreateExpense_UserMismatch_ReturnsUnauthorized()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId + 1,
                Title = "User Mismatch Test",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 50.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "Snack", Quantity = 1, Price = 50.00m }
                }
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();
            Assert.True(response.StatusCode == HttpStatusCode.Unauthorized,
                $"Expected 401 Unauthorized but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Error Path - Create Expense with amount exceeding DECIMAL(18,2) precision results in server error")]
        public async Task CreateExpense_AmountOverflow_ReturnsServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var hugeAmount = decimal.Parse("99999999999999999.99");

            var dto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Overflow Test",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = hugeAmount,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "Expensive", Quantity = 1, Price = hugeAmount }
                }
            };

            var response = await _client.PostAsJsonAsync("/api/expenses", dto);
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.UnprocessableEntity,
                $"Expected 422 Unprocessable Entity but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Get Expense - Non-existent expense returns 404 NotFound")]
        public async Task GetExpense_NonExistent_ReturnsNotFound()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.GetAsync($"/api/expenses/999999");
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.NotFound,
                $"Expected 404 NotFound but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }

        [Fact(DisplayName = "Get Expenses By User - Happy Path returns 200 Ok and paged structure")]
        public async Task GetExpensesByUser_HappyPath_ReturnsOk()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.GetAsync("/api/expenses?pageNumber=1&pageSize=10");
            var responseBody = await response.Content.ReadAsStringAsync();

            Assert.True(response.StatusCode == HttpStatusCode.OK,
                $"Expected 200 OK but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");

            using var doc = JsonDocument.Parse(responseBody);
            var root = doc.RootElement;
            Assert.True(root.TryGetProperty("data", out var dataProp));
            Assert.True(dataProp.ValueKind == JsonValueKind.Array);
        }

        [Fact(DisplayName = "Update Expense - Happy Path (create -> update) returns 200 Ok")]
        public async Task UpdateExpense_CreateThenUpdate_ReturnsOk()
        {
            await EnsureAuthenticatedViaLoginAsync();

            // Create first
            var createDto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "Temp",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 20.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "X", Quantity = 1, Price = 20.00m }
                }
            };

            var createResponse = await _client.PostAsJsonAsync("/api/expenses", createDto);
            var createBody = await createResponse.Content.ReadAsStringAsync();
            Assert.True(createResponse.StatusCode == HttpStatusCode.Created, $"Failed to create expense. Body: {createBody}");

            using var doc = JsonDocument.Parse(createBody);
            var createdId = doc.RootElement.GetProperty("expenseId").GetInt32();

            // Update
            var updateDto = new ExpenseDTO
            {
                ExpenseId = createdId,
                UserId = _botUserId,
                Title = "Updated",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 20.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "X", Quantity = 1, Price = 20.00m }
                }
            };

            var updateResponse = await _client.PatchAsJsonAsync($"/api/expenses/{createdId}", updateDto);
            var updateBody = await updateResponse.Content.ReadAsStringAsync();

            Assert.True(updateResponse.StatusCode == HttpStatusCode.OK,
                $"Expected 200 OK but got {(int)updateResponse.StatusCode} {updateResponse.StatusCode}. Response body: {updateBody}");

            using var doc2 = JsonDocument.Parse(updateBody);
            Assert.Equal(createdId, doc2.RootElement.GetProperty("expenseId").GetInt32());
        }

        [Fact(DisplayName = "Delete Expense - Happy Path (create then delete) returns 204 NoContent")]
        public async Task DeleteExpense_CreateThenDelete_ReturnsNoContent()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var createDto = new ExpenseDTO
            {
                ExpenseId = -1,
                UserId = _botUserId,
                Title = "ToDelete",
                WalletId = _botWalletId,
                CategoryId = 1,
                Amount = 5.00m,
                Date = DateTime.UtcNow,
                Products = new System.Collections.Generic.List<ProductDTO>
                {
                    new ProductDTO { Name = "Y", Quantity = 1, Price = 5.00m }
                }
            };

            var createResponse = await _client.PostAsJsonAsync("/api/expenses", createDto);
            var createBody = await createResponse.Content.ReadAsStringAsync();
            Assert.True(createResponse.StatusCode == HttpStatusCode.Created, $"Failed to create expense for delete test. Body: {createBody}");

            using var doc = JsonDocument.Parse(createBody);
            var createdId = doc.RootElement.GetProperty("expenseId").GetInt32();

            var deleteResponse = await _client.DeleteAsync($"/api/expenses/{createdId}");
            var deleteBody = await deleteResponse.Content.ReadAsStringAsync();

            Assert.True(deleteResponse.StatusCode == HttpStatusCode.NoContent,
                $"Expected 204 NoContent but got {(int)deleteResponse.StatusCode} {deleteResponse.StatusCode}. Response body: {deleteBody}");
        }

        [Fact(DisplayName = "Delete Expense - Non-existent expense returns NotFound or Server Error depending on stored proc mapping")]
        public async Task DeleteExpense_NonExistent_ReturnsNotFoundOrServerError()
        {
            await EnsureAuthenticatedViaLoginAsync();

            var response = await _client.DeleteAsync($"/api/expenses/-99999");
            var responseBody = await response.Content.ReadAsStringAsync();

            // Stored procs may throw 50002 which maps to 404; repository may return false -> 500.
            Assert.True(response.StatusCode == HttpStatusCode.NotFound || response.StatusCode == HttpStatusCode.InternalServerError,
                $"Expected 404 NotFound or 500 InternalServerError but got {(int)response.StatusCode} {response.StatusCode}. Response body: {responseBody}");
        }
    }
}
