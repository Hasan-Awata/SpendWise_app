using Microsoft.Data.SqlClient;
using System;

namespace SpendWise.Infrastructure.Global
{
    public static class SqlExceptionHandler
    {
        /// <summary>
        /// Translates raw SQL Exceptions into domain-specific C# Exceptions.
        /// </summary>
        public static void Handle(SqlException ex)
        {
            if (ex.Number >= 50000)
            {
                if (ex.Number == 50001 || ex.Number == 50002)
                    throw new InvalidReferenceException(ex.Message);

                if (ex.Number == 50003)
                    throw new UnauthorizedAccessException(ex.Message);
            }

            // Standard SQL Server Engine Errors
            switch (ex.Number)
            {
                case 2601:
                case 2627:
                    throw new DuplicateResourceException("This resource already exists or violates a unique constraint.");

                case 547:
                    throw new InvalidReferenceException("A related record is missing, or you are trying to modify a record currently in use.");

                case -2:
                    throw new TimeoutException("The database took too long to respond. Please try again.");

                default:
                    // Fallback for anything else
                    throw new Exception($"An unexpected database error occurred. Code: {ex.Number} - {ex.Message}");
            }
        }
    }
}