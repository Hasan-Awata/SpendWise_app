using SpendWise.Application.DTOs.NewFolder;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Interfaces.Wallets
{
    public interface IWalletRepository
    {
        public Task<Wallet?> GetWalletByIdAsync(int walletId, int userId);

        public Task<IEnumerable<Wallet>> GetUserWalletsAsync(int userId);

        public Task<int> AddWalletAsync(Wallet wallet);

        public Task<bool> UpdateWalletAsync(Wallet wallet);

        public Task<bool> DeleteWalletAsync(int walletId);

    }
}
