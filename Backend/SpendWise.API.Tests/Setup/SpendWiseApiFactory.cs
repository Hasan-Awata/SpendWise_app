using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.RateLimiting; 
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection; 

namespace SpendWise.API.Tests.Setup
{
    public class SpendWiseApiFactory : WebApplicationFactory<Program>
    {
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureAppConfiguration((context, configBuilder) =>
            {
                configBuilder.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    { "ConnectionStrings:DefaultConnection", "Server=.;Database=SpendWise_TestDB;Trusted_Connection=True;TrustServerCertificate=True;" },
                    { "JwtSettings:SecretKey", "This-is-a-development-only-key-do-not-use-on-deployment" },
                    { "JwtSettings:Issuer", "SpendWise" },
                    { "JwtSettings:Audience", "SpendWiseUsers" },
                    { "JwtSettings:ExpiryInMinutes", "60" }
                });
            });

            // FIX FOR THE RATE LIMITER DISABLING DURING TESTS
            builder.ConfigureServices(services =>
            {
                // Disable rate limiting by clearing out existing rate limits rules or over-riding them
                services.Configure<RateLimiterOptions>(options =>
                {
                    options.GlobalLimiter = null; // Remove global limitations

                    // Add a wide open fallback "Fixed" policy specifically for testing targets
                    options.AddFixedWindowLimiter("Fixed", opt =>
                    {
                        opt.PermitLimit = int.MaxValue;
                        opt.Window = TimeSpan.FromSeconds(1);
                    });
                });
            });
        }
    }
}