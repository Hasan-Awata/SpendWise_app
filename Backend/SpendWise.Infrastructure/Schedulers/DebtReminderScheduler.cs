using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;

namespace SpendWise.Infrastructure.ExternalServices
{
    public class DebtReminderScheduler : BackgroundService
    {
        private readonly IConfiguration _configuration;
        public DebtReminderScheduler(IConfiguration configuration)
        {
            _configuration = configuration;

            // Safe initialization fallback for Firebase across different background threads
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
            // Run this validation check once every 24 hours
            using var timer = new PeriodicTimer(TimeSpan.FromDays(1));

            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    string connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException(nameof(_configuration), "Connection string is missing in appsettings.");
                    using var connection = new SqlConnection(connectionString);
                    using var command = new SqlCommand("sp_GetUpcomingDebtReminders", connection);
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync(stoppingToken);
                    using var reader = await command.ExecuteReaderAsync(stoppingToken);

                    while (await reader.ReadAsync(stoppingToken))
                    {
                        string title = reader.GetString(reader.GetOrdinal("Title"));
                        decimal remainingAmount = reader.GetDecimal(reader.GetOrdinal("RemainingAmount"));
                        string fcmToken = reader.GetString(reader.GetOrdinal("FcmToken"));

                        await DispatchDebtReminderNotification(fcmToken, title, remainingAmount);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[DebtReminderScheduler] Error running background reminders: {ex.Message}");
                }
            }
        }

        private async Task DispatchDebtReminderNotification(string deviceToken, string debtTitle, decimal amount)
        {
            var message = new Message()
            {
                Notification = new Notification()
                {
                    Title = "Upcoming Debt Reminder ⏰",
                    Body = $"The debt '{debtTitle}' has a remaining balance of {amount:N2} due in 2 days."
                },
                Token = deviceToken
            };

            try
            {
                await FirebaseMessaging.DefaultInstance.SendAsync(message);
            }
            catch (FirebaseMessagingException ex)
            {
                Console.WriteLine($"[DebtReminderScheduler] FCM delivery failure: {ex.Message}");
            }
        }
    }
}