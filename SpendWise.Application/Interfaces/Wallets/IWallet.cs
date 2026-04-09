using SpendWise.Application.DTOs.NewFolder;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Wallets
{
    public  interface IWallet
    {
    public Task<Wallet?> GetWalletByIdAsync(int walletId, int userId);
   
    public Task<IEnumerable<Wallet>> GetUserWalletsAsync(int userId);
 
    public Task<bool> AddWalletAsync(WalletsDTO createWalletDto);
   
    public Task<bool> UpdateWalletAsync(WalletsDTO updateWalletDto, int WalletID);
    
    public Task<bool> DeleteWalletAsync(int walletId, int userId);
    
    public Task<decimal> GetTotalBalanceAsync(int userId, int currencyId);
    }
}
