using System;

namespace SpendWise.Infrastructure.Global
{
    // The Base Exception
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
}