using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace SpendWise.Middlewares
{
    public class SecurityHeadersMiddleware
    {
        private readonly RequestDelegate _next;

        public SecurityHeadersMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // 1. Prevent the API from being embedded in an iframe (Anti-Clickjacking)
            if (!context.Response.Headers.ContainsKey("X-Frame-Options"))
            {
                context.Response.Headers.Append("X-Frame-Options", "DENY");
            }

            // 2. Prevent browsers from guessing/sniffing the MIME type
            if (!context.Response.Headers.ContainsKey("X-Content-Type-Options"))
            {
                context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
            }

            // 3. Control how much referral info is shared when navigating away
            if (!context.Response.Headers.ContainsKey("Referrer-Policy"))
            {
                context.Response.Headers.Append("Referrer-Policy", "no-referrer");
            }

            // 4. Force modern browsers to only interact with the API over HTTPS
            if (!context.Response.Headers.ContainsKey("Strict-Transport-Security"))
            {
                context.Response.Headers.Append("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            }

            // 5. Restrict browser features (like camera, microphone, geolocation)
            if (!context.Response.Headers.ContainsKey("Permissions-Policy"))
            {
                context.Response.Headers.Append("Permissions-Policy", "accelerometer=(), camera=(), microphone=(), geolocation=()");
            }

            // 6. Basic Content Security Policy (CSP) for APIs
            if (!context.Response.Headers.ContainsKey("Content-Security-Policy"))
            {
                context.Response.Headers.Append("Content-Security-Policy", "default-src 'self'; frame-ancestors 'none';");
            }

            // Call the next middleware in the pipeline
            await _next(context);
        }
    }

    // Extension method to make registration clean in Program.cs
    public static class SecurityHeadersMiddlewareExtensions
    {
        public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<SecurityHeadersMiddleware>();
        }
    }
}