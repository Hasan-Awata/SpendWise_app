using SpendWise.Application.DTOs.Wallet;
using SpendWise.Application.DTOs.Currency;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;
using SpendWise.Application.DTOs.NewFolder;

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
                Currency = new CurrencyResponse
                {
                    Id = wallet.Currency.Id,
                    CurrencyName = wallet.Currency.CurrencyName,
                    LiveValue = wallet.Currency.LiveValue,
                }
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
                Currency = new CurrencyResponse
                {
                    Id= item.Currency.Id,
                    CurrencyName= item.Currency.CurrencyName,
                    LiveValue= item.Currency.LiveValue,
                },
            });
        }

        public async Task<WalletResponse?> AddWalletAsync(WalletDTO walletDTO)
        {
            var newWallet = new Wallet
            {
                WalletId = walletDTO.WalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                Currency = new Currency
                {
                    Id = walletDTO.CurrencyDTO.CurrencyId,
                    CurrencyName = walletDTO.CurrencyDTO.CurrencyName,
                    LiveValue = walletDTO.CurrencyDTO.LiveValue,
                }
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
                Currency = new CurrencyResponse
                {
                    Id = walletDTO.CurrencyDTO.CurrencyId,
                    CurrencyName = walletDTO.CurrencyDTO.CurrencyName,
                    LiveValue = walletDTO.CurrencyDTO.LiveValue,
                },
            };
        }

        public async Task<WalletResponse?> UpdateWalletAsync(WalletDTO walletDTO)
        {
            var updatedWallet = new Wallet
            {
                WalletId = walletDTO.WalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                Currency = new Currency
                {
                    Id = walletDTO.CurrencyDTO.CurrencyId,
                    CurrencyName = walletDTO.CurrencyDTO.CurrencyName,
                    LiveValue = walletDTO.CurrencyDTO.LiveValue,
                }
            };

            int updatedWalletId = await _walletRepo.UpdateWalletAsync(updatedWallet);

            if(updatedWalletId == -1)
            {
                return null;
            }

            return new WalletResponse
            {
                WalletId = updatedWalletId,
                UserId = walletDTO.UserId,
                Balance = walletDTO.Balance,
                Currency = new CurrencyResponse
                {
                    Id = walletDTO.CurrencyDTO.CurrencyId,
                    CurrencyName = walletDTO.CurrencyDTO.CurrencyName,
                    LiveValue = walletDTO.CurrencyDTO.LiveValue,
                },
            };
        }

        public async Task<bool> DeleteWalletAsync(int walletId)
        {
            return await _walletRepo.DeleteWalletAsync(walletId);
        }
    } 
}
