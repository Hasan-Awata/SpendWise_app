using System;

namespace SpendWise.Domain.Common
{
    /// <summary>
    /// Thrown when an entity or resource (Wallet, Category, Transaction) is requested but does not exist.
    /// Maps cleanly to an HTTP 404 Not Found.
    /// </summary>
    public class ResourceNotFoundException : Exception
    {
        public ResourceNotFoundException() : base() { }
        public ResourceNotFoundException(string message) : base(message) { }
        public ResourceNotFoundException(string message, Exception innerException) : base(message, innerException) { }
    }

    /// <summary>
    /// Thrown when a business operation fails validation rules (e.g., trying to spend money out of a frozen account).
    /// Maps cleanly to an HTTP 400 Bad Request or 422 Unprocessable Entity.
    /// </summary>
    public class WrongOperationException : Exception
    {
        public WrongOperationException() : base() { }
        public WrongOperationException(string message) : base(message) { }
        public WrongOperationException(string message, Exception innerException) : base(message, innerException) { }
    }

    /// <summary>
    /// Thrown when a user attempts to create a resource that already exists (e.g., duplicate unique emails or SKUs).
    /// Maps cleanly to an HTTP 409 Conflict.
    /// </summary>
    public class DuplicateResourceException : Exception
    {
        public DuplicateResourceException() : base() { }
        public DuplicateResourceException(string message) : base(message) { }
        public DuplicateResourceException(string message, Exception innerException) : base(message, innerException) { }
    }

    /// <summary>
    /// Thrown when an operations violates relational setups (e.g., assigning a transaction to an invalid ID).
    /// Maps cleanly to an HTTP 400 Bad Request.
    /// </summary>
    public class InvalidReferenceException : Exception
    {
        public InvalidReferenceException() : base() { }
        public InvalidReferenceException(string message) : base(message) { }
        public InvalidReferenceException(string message, Exception innerException) : base(message, innerException) { }
    }

    /// <summary>
    /// Specific fintech domain exception thrown when a wallet balance would drop below zero.
    /// Maps cleanly to an HTTP 422 Unprocessable Entity or 400 Bad Request.
    /// </summary>
    public class InsufficientFundsException : Exception
    {
        public InsufficientFundsException() : base() { }
        public InsufficientFundsException(string message) : base(message) { }
        public InsufficientFundsException(string message, Exception innerException) : base(message, innerException) { }
    }
}