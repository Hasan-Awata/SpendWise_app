using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

public class FixedIncomeScheduler : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IConfiguration _configuration;

    public FixedIncomeScheduler(IServiceProvider serviceProvider, IConfiguration configuration)
    {
        _serviceProvider = serviceProvider;
        _configuration = configuration;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Set the timer to run every 24 hours (adjust as needed)
        using var timer = new PeriodicTimer(TimeSpan.FromDays(1));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                string connectionString = _configuration.GetConnectionString("DefaultConnection") ?? throw new ArgumentNullException(nameof(_configuration), "Connection string is missing in appsettings.");
                using var connection = new SqlConnection(connectionString);
                using var command = new SqlCommand("sp_ProcessDueFixedIncomes", connection);
                command.CommandType = CommandType.StoredProcedure;

                await connection.OpenAsync(stoppingToken);

                // Execute the ADO.NET command
                int rowsAffected = await command.ExecuteNonQueryAsync(stoppingToken);

                Console.WriteLine($"Processed fixed incomes. Rows affected: {rowsAffected}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error processing fixed incomes: {ex.Message}");
            }
        }
    }
}