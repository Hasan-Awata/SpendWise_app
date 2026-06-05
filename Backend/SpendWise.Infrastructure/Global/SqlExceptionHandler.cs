using Microsoft.Data.SqlClient;
using System;
using System.Data;

namespace SpendWise.Infrastructure.Global
{
    public static class SqlExceptionHandler
    {
        public static void Handle(SqlException ex)
        {
            // 1. Extract exact SQL location for ultra-clean debugging
            string procName = string.IsNullOrEmpty(ex.Errors[0].Procedure) ? "Inline SQL" : ex.Errors[0].Procedure;
            string debugInfo = $"[Proc: {procName} | Line: {ex.Errors[0].LineNumber}] ";

            // 2. Custom User-Defined Errors (Thrown manually via THROW in Stored Procedures)
            if (ex.Number >= 50000)
            {
                // Inject the debug location directly into the error message
                string fullMessage = $"{debugInfo}{ex.Message}";

                switch (ex.Number)
                {
                    case 50001:
                        throw new InvalidReferenceException(fullMessage); 
                    case 50002:
                        throw new ResourceNotFoundException(fullMessage); 
                    case 50003:
                        throw new UnauthorizedAccessException(fullMessage); 
                    case 50004:
                        throw new DuplicateResourceException(fullMessage); 
                    case 50005:
                        throw new WrongOperation(fullMessage); 
                    default:
                        throw new Exception(fullMessage); 
                }
            }

            // 3. Standard SQL Server Engine Errors
            switch (ex.Number)
            {
                // -- DATA INTEGRITY & CONSTRAINTS --
                case 2601: // Duplicated key row error
                case 2627: // Unique constraint error
                    throw new DuplicateResourceException($"{debugInfo}This resource already exists or violates a unique constraint.");

                case 547: // Foreign Key or Check Constraint violation
                    throw new InvalidReferenceException($"{debugInfo}A related record is missing, or a constraint was violated (e.g., Dates, Invalid IDs).");

                case 515: // Cannot insert NULL
                    throw new ArgumentException($"{debugInfo}A required field was left empty (NULL violation).");

                case 8152: // String or binary data would be truncated (SQL Server 2017-)
                case 2628: // String or binary data would be truncated (SQL Server 2019+)
                    throw new ArgumentException($"{debugInfo}The provided data is too long for one or more fields.");

                case 245: // Conversion failed
                    throw new ArgumentException($"{debugInfo}Data type conversion failed. Please ensure the data format is correct.");

                // -- CONCURRENCY --
                case 1205: // Deadlock victim
                    throw new DataException($"{debugInfo}The database is currently busy processing conflicting requests. Please retry.");

                // -- TIMEOUTS & CONNECTIONS --
                case -2: // Timeout
                    throw new TimeoutException($"{debugInfo}The database took too long to respond. Please try again.");

                case 2:     // Connection failed
                case 53:    // Named Pipes Provider error / Server not found
                case 4060:  // Cannot open database
                case 18456: // Login failed
                    throw new InvalidOperationException($"{debugInfo}Failed to connect to the database. Check server status.");

                // -- SCHEMA & MISSING OBJECTS --
                case 207:  // Invalid column name
                case 208:  // Invalid object name (Table missing)
                case 2812: // Could not find stored procedure
                    throw new InvalidOperationException($"{debugInfo}Database schema mismatch. Code {ex.Number}: {ex.Message}");

                // -- FALLBACK --
                default:
                    throw new Exception($"Database Error: SQL Error [{ex.Number}]: {ex.Message} {debugInfo}");
            }
        }
    }
}