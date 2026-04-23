using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using SpendWise.Infrastructure.Global; // Make sure to include this
using System.Data;

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

            var (statusCode, title, detail) = exception switch
            {
                // Catches ALL custom exceptions.
                SpendWiseException customEx => (customEx.StatusCode, customEx.Title, customEx.Message),

                // Catches the remaining system exceptions.
                UnauthorizedAccessException ex => (StatusCodes.Status401Unauthorized, "Unauthorized", ex.Message),
                ArgumentException ex => (StatusCodes.Status400BadRequest, "Bad Request", ex.Message),
                DataException ex => (StatusCodes.Status503ServiceUnavailable, "Service Busy", ex.Message),
                TimeoutException ex => (StatusCodes.Status504GatewayTimeout, "Gateway Timeout", ex.Message),

                // The Global Fallback
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