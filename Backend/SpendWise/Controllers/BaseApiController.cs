using Microsoft.AspNetCore.Mvc;
using SpendWise.Domain.Common;
using SpendWise.Domain.Enums;
using System;
using System.Security.Claims;

namespace SpendWise.Controllers
{
    [ApiController] 
    public abstract class BaseApiController : ControllerBase
    {
        protected int CurrentUserId
        {
            get
            {
                var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (int.TryParse(userIdString, out int userId))
                {
                    return userId;
                }

                throw new UnauthorizedAccessException("User ID claim is missing or invalid.");
            }
        }

        protected ActionResult HandleResultOnError<T>(Result<T> result)
        {
            var errorResponse = new { message = result.ErrorMessage };

            return result.ErrorType switch
            {
                enErrorType.Validation => BadRequest(errorResponse),
                enErrorType.NotFound => NotFound(errorResponse),
                enErrorType.BalanceViolation => UnprocessableEntity(errorResponse),
                _ => StatusCode(500, new { message = errorResponse })
            };
        }

        protected ActionResult HandleResultOnError(Result result)
        {
            var errorResponse = new { message = result.ErrorMessage };

            return result.ErrorType switch
            {
                enErrorType.Validation => BadRequest(errorResponse),
                enErrorType.NotFound => NotFound(errorResponse),
                enErrorType.BalanceViolation => UnprocessableEntity(errorResponse),
                _ => StatusCode(500, new { message = errorResponse })
            };
        }
    }
}