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

        public Task<int> AddWalletAsync(Wallet walletDTO);

        public Task<int> UpdateWalletAsync(Wallet walletDTO);

        public Task<bool> DeleteWalletAsync(int walletId);

    }
}
