using System;

public class DuplicateResourceException : Exception
{
    public DuplicateResourceException(string message) : base(message) { }
}

public class InvalidReferenceException : Exception
{
    public InvalidReferenceException(string message) : base(message) { }
}