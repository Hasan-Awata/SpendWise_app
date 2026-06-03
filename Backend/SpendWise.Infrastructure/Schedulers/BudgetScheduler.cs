using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;

namespace SpendWise.Infrastructure.ExternalServices
{
    public class BudgetScheduler : BackgroundService
    {
        private readonly IConfiguration _configuration;
        public BudgetScheduler(IConfiguration configuration)
        {
            _configuration = configuration;

            // Ensure Firebase app instance is initialized for this thread context
            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile("firebase-adminsdk.json")
                });
            }
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var timer = new PeriodicTimer(TimeSpan.FromDays(1));

            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    string connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException(nameof(_configuration), "Connection string is missing in appsettings.");
                    using var connection = new SqlConnection(connectionString);
                    using var command = new SqlCommand("sp_ResetExpiredBudgets", connection);
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync(stoppingToken);
                    using var reader = await command.ExecuteReaderAsync(stoppingToken);

                    // Loop through all budgets that rolled over and alert their owners
                    while (await reader.ReadAsync(stoppingToken))
                    {
                        decimal limit = reader.GetDecimal(reader.GetOrdinal("PercentageLimit"));
                        string fcmToken = reader.GetString(reader.GetOrdinal("FcmToken"));

                        await DispatchBudgetResetNotification(fcmToken, limit);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[BudgetScheduler] Error: {ex.Message}");
                }
            }
        }

        private async Task DispatchBudgetResetNotification(string deviceToken, decimal limit)
        {
            var message = new Message()
            {
                Notification = new Notification()
                {
                    Title = "Budget Cycle Reset! 🔄",
                    Body = $"Your budget limit of {limit:N2} has reset for the new period. Fresh start!"
                },
                Token = deviceToken
            };

            try
            {
                await FirebaseMessaging.DefaultInstance.SendAsync(message);
            }
            catch (FirebaseMessagingException ex)
            {
                Console.WriteLine($"[BudgetScheduler] FCM delivery error: {ex.Message}");
            }
        }
    }
}