using System.Collections.Generic;

namespace SpendWise.Infrastructure.Global
{
    public static class DomainErrorMessages
    {
        private static readonly Dictionary<string, string> Messages = new ()
        {
            // Wallet
            { "ERR_ResourceNotFound_Wallet", "The requested wallet could not be found." },
            { "ERR_UnauthorizedAccess_WalletOwner", "Access denied. You do not have permission to use this wallet." },
            { "ERR_InsufficientFunds_WalletBalance", "Transaction declined. You don't have enough balance." },
            
        };

        public static string GetMessage(string errorKey)
        {
            return Messages.TryGetValue(errorKey, out var message)
                ? message
                : "A business rule violation occurred.";
        }
    }
}