using System.Data;
using Microsoft.Data.SqlClient;
using SpendWise.Infrastructure.Global;

public abstract class BaseRepository
{
    private readonly string _connectionString;

    // The constructor takes the connection string so child classes can pass it up
    protected BaseRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    // 1. GLOBAL EXECUTE SCALAR
    protected async Task<T?> ExecuteScalarAsync<T>(string procedureName, Action<SqlCommand> parameters)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(procedureName, connection);
            command.CommandType = CommandType.StoredProcedure;

            parameters(command); // Run the lambda to inject parameters

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();

            if (result == null || result == DBNull.Value)
                return default;

            return (T)Convert.ChangeType(result, typeof(T));
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    // 2. GLOBAL EXECUTE READER (FOR LISTS)
    protected async Task<List<T>> ExecuteReaderAsync<T>(string procedureName, Action<SqlCommand> parameters, Func<SqlDataReader, T> mapRow)
    {
        var list = new List<T>();

        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(procedureName, connection);
            command.CommandType = CommandType.StoredProcedure;

            parameters(command);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                list.Add(mapRow(reader)); // Map individual rows dynamically
            }

            return list;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }

    // 3. GLOBAL EXECUTE READER SINGLE (FOR A SINGLE RECORD)
    protected async Task<T?> ExecuteReaderSingleAsync<T>(string procedureName, Action<SqlCommand> parameters, Func<SqlDataReader, T> mapRow)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(procedureName, connection);
            command.CommandType = CommandType.StoredProcedure;

            parameters(command);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return mapRow(reader);
            }

            return default;
        }
        catch (SqlException ex)
        {
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }
    protected async Task<int> ExecuteNonQueryAsync(string storedProcedure, Action<SqlCommand> configureParameters)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand(storedProcedure, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            configureParameters?.Invoke(command);

            await connection.OpenAsync();
            return await command.ExecuteNonQueryAsync();
        }
        catch (SqlException ex)
        { 
            SqlExceptionHandler.Handle(ex);
            throw;
        }
    }
}