using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Domain.Common;
using SpendWise.Application.DTOs.Wallet;

namespace SpendWise.Application.Interfaces.Wallets
{
    public  interface IWalletService
    {
        public Task<Result<WalletResponse>> GetWalletByIdAsync(int walletId, int userId);
   
        public Task<Result<IEnumerable<WalletResponse>>> GetUserWalletsAsync(int userId);
        public Task<Result<IEnumerable<WalletResponse>>> GetWalletsByCurrencyIdAsync(int userId, int currencyId);
        public Task<Result<IEnumerable<WalletResponse>>> GetUserWalletsPairAsync(int userId, int walletId);

        public Task<Result<WalletResponse>> AddWalletAsync(WalletDTO walletDTO);
   
        public Task<Result<WalletResponse>> UpdateWalletAsync(WalletDTO walletDTO);
    
        public Task<Result> DeleteWalletAsync(int walletId, int userId);    
    }
}
