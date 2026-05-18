using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public class WalletService : IWalletService
    {
        private readonly IWalletRepository _walletRepo;

        public WalletService(IWalletRepository walletRepo)
        {
            _walletRepo = walletRepo;
        }

        public async Task<WalletResponse?> GetWalletByIdAsync(int walletId, int userId)
        {
            var wallet = await _walletRepo.GetWalletByIdAsync(walletId, userId);

            if(wallet == null)
            {
                return null;
            }

            return new WalletResponse
            {
                WalletId = walletId,
                UserId = userId,
                Balance = wallet.Balance,
                CurrencyId = wallet.CurrencyId,
                IsSaved = wallet.IsSaved,
            };
        }

        public async Task<IEnumerable<WalletResponse>> GetUserWalletsAsync(int userId)
        {
            var walletsList = await _walletRepo.GetUserWalletsAsync(userId);

            if (!walletsList.Any())
            {
                return Enumerable.Empty<WalletResponse>();
            }

            return walletsList.Select(item => new WalletResponse
            {
                WalletId = item.WalletId,
                UserId = item.UserId,
                Balance = item.Balance,
                CurrencyId = item.CurrencyId,
                IsSaved= item.IsSaved,
            }).ToList();
        }

        public async Task<WalletResponse?> AddWalletAsync(WalletDTO walletDTO)
        {
            var newWallet = new Wallet
            {
                WalletId = walletDTO.WalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                IsSaved = walletDTO.IsSaved,
                CurrencyId = walletDTO.CurrencyId,
            };

            int newWalletId = await _walletRepo.AddWalletAsync(newWallet);

            if(newWalletId == -1)
            {
                return null;
            }

            return new WalletResponse
            {
                WalletId = newWalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                IsSaved= walletDTO.IsSaved,
                CurrencyId = walletDTO.CurrencyId,
            };
        }

        public async Task<WalletResponse?> UpdateWalletAsync(WalletDTO walletDTO)
        {
            var updatedWallet = new Wallet
            {
                WalletId = walletDTO.WalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                IsSaved = walletDTO.IsSaved,
                CurrencyId = walletDTO.CurrencyId,
            };

            if(!await _walletRepo.UpdateWalletAsync(updatedWallet))
                return null;

            return new WalletResponse
            {
                WalletId = walletDTO.WalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                CurrencyId = walletDTO.CurrencyId,
                IsSaved = walletDTO.IsSaved,
            };
        }

        public async Task<bool> DeleteWalletAsync(int walletId, int userId)
        {
            return await _walletRepo.DeleteWalletAsync(walletId, userId);
        }
    } 
}
