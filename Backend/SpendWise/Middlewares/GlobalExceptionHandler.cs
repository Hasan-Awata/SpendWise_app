using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace SpendWise.Middlewares
{
    public class GlobalExceptionHandler : IExceptionHandler
    {
        private readonly ILogger<GlobalExceptionHandler> _logger;

        public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
        {
            _logger = logger;
        }

        public async ValueTask<bool> TryHandleAsync(
            HttpContext httpContext,
            Exception exception,
            CancellationToken cancellationToken)
        {
            // 1. Log the full error for debugging
            _logger.LogError(exception, "An unhandled exception occurred: {Message}", exception.Message);

            // 2. Set up the standard response structure
            var problemDetails = new ProblemDetails
            {
                Instance = httpContext.Request.Path
            };

            // 3. Map the specific custom exceptions to HTTP Status Codes
            switch (exception)
            {
                case DuplicateResourceException duplicateEx:
                    httpContext.Response.StatusCode = StatusCodes.Status409Conflict;
                    problemDetails.Title = "Resource Conflict";
                    problemDetails.Detail = duplicateEx.Message;
                    problemDetails.Status = StatusCodes.Status409Conflict;
                    break;

                case InvalidReferenceException referenceEx:
                    httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
                    problemDetails.Title = "Invalid Reference";
                    problemDetails.Detail = referenceEx.Message;
                    problemDetails.Status = StatusCodes.Status400BadRequest;
                    break;

                case UnauthorizedAccessException unauthorizedEx:
                    httpContext.Response.StatusCode = StatusCodes.Status401Unauthorized;
                    problemDetails.Title = "Unauthorized";
                    problemDetails.Detail = unauthorizedEx.Message;
                    problemDetails.Status = StatusCodes.Status401Unauthorized;
                    break;

                default:
                    // 4. The Fallback for unexpected crashes (NullReferenceException, Database drops, etc.)
                    httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
                    problemDetails.Title = "Internal Server Error";
                    problemDetails.Detail = "An unexpected error occurred. Please try again later.";
                    problemDetails.Status = StatusCodes.Status500InternalServerError;
                    break;
            }

            // 5. Write the JSON response back to the client
            await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);

            // Return true to tell ASP.NET Core that we successfully handled the error
            return true;
        }
    }
}