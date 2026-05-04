using System;

namespace SpendWise.Infrastructure.Global
{
    public abstract class SpendWiseException : Exception
    {
        public int StatusCode { get; }
        public string Title { get; }

        protected SpendWiseException(string message, int statusCode, string title)
            : base(message)
        {
            StatusCode = statusCode;
            Title = title;
        }
    }

    public class DuplicateResourceException : SpendWiseException
    {
        public DuplicateResourceException(string message)
            : base(message, 409, "Resource Conflict") { }
    }

    public class InvalidReferenceException : SpendWiseException
    {
        public InvalidReferenceException(string message)
            : base(message, 400, "Invalid Reference") { }
    }

    public class WrongOperation : SpendWiseException
    {
        public WrongOperation(string message)
            : base(message, 400, "Wrong Operation") { }
    }

    public class ResourceNotFoundException : SpendWiseException
    {
        public ResourceNotFoundException(string message)
            : base(message, 404, "Resource Not Found") { }
    }
}