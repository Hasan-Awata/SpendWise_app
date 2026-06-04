using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using System.Data;

public class FixedExpenseScheduler : BackgroundService
{
    private readonly IConfiguration _configuration;

    public FixedExpenseScheduler(IConfiguration configuration)
    {
        _configuration = configuration;

        // Initialize Firebase Admin SDK once during service instantiation
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

        try
        {
            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    string connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException(nameof(_configuration), "Connection string is missing in appsettings.");
                    using var connection = new SqlConnection(connectionString);
                    using var command = new SqlCommand("sp_ProcessDueFixedExpenses", connection);
                    command.CommandType = CommandType.StoredProcedure;

                    await connection.OpenAsync(stoppingToken);

                    // Read the tokens returned by the modified stored procedure
                    using var reader = await command.ExecuteReaderAsync(stoppingToken);

                    while (await reader.ReadAsync(stoppingToken))
                    {
                        decimal amount = reader.GetDecimal(reader.GetOrdinal("Amount"));
                        string fcmToken = reader.GetString(reader.GetOrdinal("FcmToken"));

                        // Dispatch notification to Firebase asynchronously
                        await DispatchPushNotification(fcmToken, amount);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error running execution loop: {ex.Message}");
                }
            }
        }
        catch(OperationCanceledException) { }
    }

    private async Task DispatchPushNotification(string deviceToken, decimal amount)
    {
        var message = new Message()
        {
            Notification = new Notification()
            {
                Title = "Fixed Expense Due! 💰",
                Body = $"Your fixed expense of {amount:N2} is due to be paid."
            },
            Token = deviceToken
        };

        try
        {
            await FirebaseMessaging.DefaultInstance.SendAsync(message);
        }
        catch (FirebaseMessagingException ex)
        {
            Console.WriteLine($"Firebase delivery failure: {ex.Message}");
        }
    }
}