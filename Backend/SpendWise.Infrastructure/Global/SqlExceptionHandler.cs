using Microsoft.Data.SqlClient;
using System;
using System.Data;
using System.Reflection;
using SpendWise.Domain.Common;

namespace SpendWise.Infrastructure.Global
{
    public static class SqlExceptionHandler
    {
        // 1. Target your custom exceptions assembly
        private static readonly Assembly CustomExceptionAssembly = typeof(ResourceNotFoundException).Assembly;
        private static readonly string CustomNamespace = typeof(ResourceNotFoundException).Namespace;

        // 2. Target the native system exceptions assembly as a backup
        private static readonly Assembly SystemAssembly = typeof(ArgumentException).Assembly;
        private static readonly string SystemNamespace = typeof(ArgumentException).Namespace; 

        public static void Handle(SqlException ex)
        {
            string procName = string.IsNullOrEmpty(ex.Errors[0].Procedure) ? "Inline SQL" : ex.Errors[0].Procedure;
            string debugInfo = $"[Proc: {procName} | Line: {ex.Errors[0].LineNumber}] ";

            if (ex.Number == 50000)
            {
                string errorCode = ex.Message; // e.g., "ERR_UnauthorizedAccess_Wallet"
                string userFriendlyText = DomainErrorMessages.GetMessage(errorCode);
                string fullMessage = $"{debugInfo}{userFriendlyText}";

                var tokens = errorCode.Split('_');
                if (tokens.Length >= 2 && tokens[0] == "ERR")
                {
                    string exceptionClassName = $"{tokens[1]}Exception"; // e.g., "UnauthorizedAccessException"

                    // Look in your custom Domain Exceptions first
                    Type exceptionType = CustomExceptionAssembly.GetType($"{CustomNamespace}.{exceptionClassName}");

                    // If not found in your custom project, look in native System exceptions
                    if (exceptionType == null)
                    {
                        exceptionType = SystemAssembly.GetType($"{SystemNamespace}.{exceptionClassName}");
                    }

                    // If a valid exception class type was found in either assembly, instantiate it
                    if (exceptionType != null)
                    {
                        var dynamicException = Activator.CreateInstance(exceptionType, fullMessage) as Exception;
                        if (dynamicException != null)
                        {
                            throw dynamicException;
                        }
                    }
                }

                // Global fallback if string parsing completely fails to match a class
                throw new Exception($"{debugInfo} Unhandled Domain Error: {errorCode} ({userFriendlyText})");
            }

            // 3. Standard SQL Server Engine Errors remain low-maintenance and fixed
            switch (ex.Number)
            {
                case 2601:
                case 2627:
                    throw new DuplicateResourceException($"{debugInfo}This resource already exists.");
                case 547:
                    throw new InvalidReferenceException($"{debugInfo}A related record is missing or a constraint was violated.");
                case 515:
                    throw new ArgumentException($"{debugInfo}A required field was left empty.");
                case 8152:
                case 2628:
                    throw new ArgumentException($"{debugInfo}The provided data is too long for one or more fields.");
                case -2:
                    throw new TimeoutException($"{debugInfo}The database took too long to respond.");

                default:
                    throw new Exception($"Database Error: SQL Error [{ex.Number}]: {ex.Message} {debugInfo}");
            }
        }
    }
}