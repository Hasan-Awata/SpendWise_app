using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.Wallet;

namespace SpendWise.Application.Interfaces.Wallets
{
    public  interface IWalletService
    {
        public Task<WalletResponse?> GetWalletByIdAsync(int walletId, int userId);
   
        public Task<IEnumerable<WalletResponse>> GetUserWalletsAsync(int userId);
 
        public Task<WalletResponse?> AddWalletAsync(WalletDTO walletDTO);
   
        public Task<WalletResponse?> UpdateWalletAsync(WalletDTO walletDTO);
    
        public Task<bool> DeleteWalletAsync(int walletId, int userId);    
    }
}
