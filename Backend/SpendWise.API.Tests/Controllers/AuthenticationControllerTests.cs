using SpendWise.API.Tests.Setup;
using SpendWise.Application.DTOs.Authentication;
using System.Net;
using System.Net.Http.Json;
using Xunit;

namespace SpendWise.API.Tests.Controllers
{
    public class AuthenticationControllerTests : IClassFixture<SpendWiseApiFactory>
    {
        private readonly HttpClient _client;

        public AuthenticationControllerTests(SpendWiseApiFactory factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task Register_WithValidData_ReturnsOkOrCreated()
        {
            // Arrange
            var uniqueUser = $"reg_{Guid.NewGuid().ToString()[..6]}";
            var registerDto = new RegisterDto
            {
                UserName = uniqueUser,
                Password = "SecurePassword123!",
                FirstName = "First",
                LastName = "Tester"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/Authentication/register", registerDto);

            // Assert
            Assert.True(response.StatusCode == HttpStatusCode.OK || response.StatusCode == HttpStatusCode.Created);

            var authData = await response.Content.ReadFromJsonAsync<ResponseAuthDto>();
            Assert.NotNull(authData);
            Assert.NotEmpty(authData.Token);
        }
    }
}