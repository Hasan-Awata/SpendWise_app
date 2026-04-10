using SpendWise.Application.DTOs.NewFolder;
using SpendWise.Application.Interfaces.Wallets;
using SpendWise.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace SpendWise.Application.Services
{
    public  class WalletService :IWallet
    {
        //private readonly IWalletRepository _walletRepo;

        //public WalletService(IWalletRepository walletRepo)
        //{
        //    _walletRepo = walletRepo;
        //}

        public async Task<bool> AddWalletAsync(WalletsDTO createWalletDto)
        {
          
             bool isDone = false;

            //isDone =await _walletRepo.AddWalletAsync(createWalletDto);
            return isDone;
            
        }

        public async Task<bool> UpdateWalletAsync(WalletsDTO updateWalletDto, int WalletId)
        {
            bool isDone = false;

            //isDone =await _walletRepo.UpdateWalletAsync(updateWalletDto,userId);
            return isDone;


        }

        public async Task<Wallet?> GetWalletByIdAsync(int walletId, int userId)
        {
            Wallet wallet=null;
           // wallet =await _walletRepo.GetByIdAsync(walletId, userId);

            if (wallet == null) return null;

           
            return new Wallet
            {
                WalletId = wallet.WalletId,
                CurrencyId = wallet.CurrencyId,
                Balance = wallet.Balance,
                UserId = wallet.UserId
                ,user=wallet.user

            };
        }

        public async Task<IEnumerable<Wallet>> GetUserWalletsAsync(int userId)
        {
            var wallets = new List<Wallet>();
            //uncomment later 
               //wallets= await _walletRepo.GetAllByUserIdAsync(userId);

            return wallets;

        }

        public async Task<bool> DeleteWalletAsync(int walletId, int userId)
        {
            //Uncomment Later <>
            //return await _walletRepo.DeleteAsync(walletId, userId);
            return false;

        }

        public async Task<decimal> GetTotalBalanceAsync(int userId, int currencyId)
        {   
            //Uncomment Later 
            //return await _walletRepo.GetSumBalanceAsync(userId, currencyId);
            return 0;
        }
    }

}
