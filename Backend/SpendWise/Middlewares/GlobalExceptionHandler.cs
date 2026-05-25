using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SpendWise.Domain.Common;
using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;

namespace SpendWise.Middlewares
{
    public class GlobalExceptionHandler : IExceptionHandler
    {
        private readonly ILogger<GlobalExceptionHandler> _logger;

        public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
        {
            _logger = logger;
        }

        public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
        {
            _logger.LogError(exception, "An unhandled exception occurred: {Message}", exception.Message);

            // Dynamically determine status code, title, and detail based on the exception type
            var (statusCode, title, detail) = exception switch
            {
                // 1. Your Custom Domain Exceptions Setup
                ResourceNotFoundException ex => (StatusCodes.Status404NotFound, "Resource Not Found", ex.Message),
                InsufficientFundsException ex => (StatusCodes.Status400BadRequest, "Insufficient Funds", ex.Message), // Or Status422UnprocessableEntity
                DuplicateResourceException ex => (StatusCodes.Status409Conflict, "Conflict", ex.Message),
                InvalidReferenceException ex => (StatusCodes.Status400BadRequest, "Invalid Reference", ex.Message),
                WrongOperationException ex => (StatusCodes.Status400BadRequest, "Invalid Operation", ex.Message),

                // 2. Native .NET System Exceptions (thrown via dynamic fallback reflection)
                UnauthorizedAccessException ex => (StatusCodes.Status401Unauthorized, "Unauthorized Access", ex.Message),
                ArgumentException ex => (StatusCodes.Status400BadRequest, "Bad Request", ex.Message),
                DataException ex => (StatusCodes.Status503ServiceUnavailable, "Database Service Busy", ex.Message),
                TimeoutException ex => (StatusCodes.Status504GatewayTimeout, "Database Timeout", ex.Message),

                // 3. Global Fallback for Unhandled Application Crashes
                _ => (StatusCodes.Status500InternalServerError, "Internal Server Error", "An unexpected error occurred. Please try again later.")
            };

            httpContext.Response.StatusCode = statusCode;

            var problemDetails = new ProblemDetails
            {
                Status = statusCode,
                Title = title,
                Detail = detail,
                Instance = httpContext.Request.Path
            };

            await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
            return true;
        }
    }
}