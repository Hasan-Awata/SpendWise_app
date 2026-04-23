using Microsoft.Data.SqlClient;
using System;
using System.Data;

namespace SpendWise.Infrastructure.Global
{
    public static class SqlExceptionHandler
    {
        /// <summary>
        /// Translates raw SQL Exceptions into domain-specific C# Exceptions.
        /// </summary>
        public static void Handle(SqlException ex)
        {
            // 1. Custom User-Defined Errors (Thrown manually via THROW in Stored Procedures)
            if (ex.Number >= 50000)
            {
                if (ex.Number == 50001 || ex.Number == 50002)
                    throw new InvalidReferenceException(ex.Message);

                if (ex.Number == 50003)
                    throw new UnauthorizedAccessException(ex.Message);

                // Fallback for any other custom errors you write in the future
                throw new Exception(ex.Message);
            }

            // 2. Standard SQL Server Engine Errors
            switch (ex.Number)
            {
                // -- DATA INTEGRITY & CONSTRAINTS --
                case 2601: // Duplicated key row error
                case 2627: // Unique constraint error
                    throw new DuplicateResourceException("This resource already exists or violates a unique constraint.");

                case 547: // Foreign Key violation
                    throw new InvalidReferenceException("A related record is missing, or you are trying to modify a record currently in use.");

                case 515: // Cannot insert NULL
                    throw new ArgumentException("A required field was left empty (NULL violation).");

                case 8152: // String or binary data would be truncated (SQL Server 2017-)
                case 2628: // String or binary data would be truncated (SQL Server 2019+)
                    throw new ArgumentException("The provided data is too long for one or more fields.");

                case 245: // Conversion failed
                    throw new ArgumentException("Data type conversion failed. Please ensure the data format is correct.");

                // -- CONCURRENCY --
                case 1205: // Deadlock victim
                    // Using standard DataException for concurrency issues
                    throw new DataException("The database is currently busy processing conflicting requests. Please retry your request.");

                // -- TIMEOUTS & CONNECTIONS --
                case -2: // Timeout
                    throw new TimeoutException("The database took too long to respond. Please try again.");

                case 2:     // Connection failed
                case 53:    // Named Pipes Provider error / Server not found
                case 4060:  // Cannot open database
                case 18456: // Login failed
                    throw new InvalidOperationException("Failed to connect to the database. Please check the server status or try again later.");

                // -- SCHEMA & MISSING OBJECTS (Usually Development/Deployment Bugs) --
                case 207:  // Invalid column name
                case 208:  // Invalid object name (Table missing)
                case 2812: // Could not find stored procedure
                    throw new InvalidOperationException($"Database schema mismatch. Code {ex.Number}: {ex.Message}. Please ensure all SQL scripts are executed.");

                // -- FALLBACK --
                default:
                    throw new Exception($"An unexpected database error occurred. Code: {ex.Number} - {ex.Message}");
            }
        }
    }
}